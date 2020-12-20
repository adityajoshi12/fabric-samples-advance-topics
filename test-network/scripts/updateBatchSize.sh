echo "Fetching the latest block"
docker exec -e CHANNEL_NAME=mychannel cli sh -c 'peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA'

echo "Decoding the configuration block into JSON format"
docker exec cli sh -c 'configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json'
echo "we can see the config.json file"
docker exec cli sh -c 'ls -lh'

echo "Current value of Batch Size"
MAXBATCHSIZEPATH=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
docker exec -e MAXBATCHSIZEPATH=$MAXBATCHSIZEPATH cli sh -c 'jq "$MAXBATCHSIZEPATH" config.json' 

echo "Updating the value Batch Size value from 10 to 20"
docker exec -e MAXBATCHSIZEPATH=$MAXBATCHSIZEPATH cli sh -c 'jq "$MAXBATCHSIZEPATH = 20" config.json > modified_config.json'
docker exec cli sh -c 'ls -lh'
docker exec -e MAXBATCHSIZEPATH=$MAXBATCHSIZEPATH cli sh -c 'jq "$MAXBATCHSIZEPATH" modified_config.json'

echo "Converting JSON to ProtoBuf"
docker exec cli sh -c 'configtxlator proto_encode --input config.json --type common.Config --output config.pb'
docker exec cli sh -c 'configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb'
docker exec cli sh -c 'ls -lh'

echo "Computing the Delta"
docker exec -e CHANNEL_NAME=mychannel cli sh -c 'configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output final_update.pb'
docker exec cli sh -c 'ls -lh'

echo "Adding the update to the envelope"
docker exec  cli sh -c 'configtxlator proto_decode --input final_update.pb --type common.ConfigUpdate | jq . > final_update.json'
docker exec  cli sh -c 'echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"mychannel\", \"type\":2}},\"data\":{\"config_update\":"$(cat final_update.json)"}}}" | jq . >  header_in_envolope.json'
docker exec cli sh -c 'configtxlator proto_encode --input header_in_envolope.json --type common.Envelope --output final_update_in_envelope.pb'
docker exec cli sh -c 'ls -lh'

echo "Signing the update"
docker exec cli sh -c 'peer channel signconfigtx -f final_update_in_envelope.pb'

echo "Initiate the Update command"
CORE_PEER_LOCALMSPID="OrdererMSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
CORE_PEER_ADDRESS=orderer.example.com:7050

docker exec -e CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID -e CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH -e CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS -e CHANNEL_NAME=mychannel  cli sh -c 'peer channel update -f final_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA'


echo "Verification"
docker exec -e CHANNEL_NAME=mychannel cli sh -c 'peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA'
docker exec cli sh -c 'configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json'
docker exec -e MAXBATCHSIZEPATH=$MAXBATCHSIZEPATH cli sh -c 'jq "$MAXBATCHSIZEPATH" config.json'