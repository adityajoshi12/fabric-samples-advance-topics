echo "Invoking chaincode using orderer1"
./scripts/transaction-ord1.sh

echo "Starting Orderer CLI Container"
docker-compose -f ./docker/docker-compose-orderer-cli.yaml up -d 

echo "Adding new orderer TLS to the system channel (system-channel)"
 ./scripts/addTLSsys-channel.sh

echo "Fetch the latest configuration block"
./scripts/fetchConfigBlock.sh

echo "Bring Orderer2 Container"
docker-compose -f ./docker/docker-compose-orderer.yaml up -d

echo "Adding new Orderer endpoint to the system channel (mychannel)"
./scripts/addEndPointSys-channel.sh

echo "System channel Size"
docker exec orderer.example.com ls -lh /var/hyperledger/production/orderer/chains/system-channel
docker exec orderer2.example.com ls -lh /var/hyperledger/production/orderer/chains/system-channel

echo "Application channel Size (before channel update)"
docker exec orderer.example.com ls -lh /var/hyperledger/production/orderer/chains/mychannel
docker exec orderer2.example.com ls -lh /var/hyperledger/production/orderer/chains/mychannel

echo "Add new orderer TLS to the application channel"
./scripts/addTLSapplication-channel.sh

echo "Adding new Orderer endpoint to the application channel (mychannel)"
./scripts/addEndPointapplication-channel.sh


echo "Application channel Size (after channel update)"
docker exec orderer.example.com ls -lh /var/hyperledger/production/orderer/chains/mychannel
docker exec orderer2.example.com ls -lh /var/hyperledger/production/orderer/chains/mychannel

echo "Invoking chaincode using orderer2"
./scripts/transaction-ord2.sh