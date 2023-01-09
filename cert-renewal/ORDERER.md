# Renewing the Orderer Certificates

## Regenerating Orderer Admin certificates

### Enroll the Orderer Admin MSP

```bash
export SUBJECT="C=US,L=51.50/-0.13/Arkansas,O=example-org,OU=admin"

fabric-ca-client enroll -d  -u https://Admin@example.com:Admin@example-pw@ca:7054 --tls.certfiles /crypto-config/tls-cert.pem  -M /crypto-config/ordererOrganizations/admin/Admin@example/msp  --csr.names=${SUBJECT}

```
### Enroll the Orderer Admin TLS

```bash
fabric-ca-client enroll -d --enrollment.profile tls -u https://Admin@example.com:Admin@example-pw@ca:7054 --tls.certfiles /crypto-config/tls-cert.pem  -M /crypto-config/ordererOrganizations/admin/Admin@example/tls  --csr.names=${SUBJECT}
```


## Regenerating Orderer Certificates

### Enroll the Orderer MSP


```bash
export SUBJECT="C=US,L=51.50/-0.13/Arkansas,O=example-org,OU=orderer"

fabric-ca-client enroll -d  -u https://orderer1:orderer1-pw@ca:7054 --tls.certfiles /crypto-config/tls-cert.pem  -M /crypto-config/ordererOrganizations/orderer/orderer1/msp  --csr.names=${SUBJECT}
```

### Enroll Orderer TLS

```bash
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer1:orderer1-pw@ca:7054 --tls.certfiles /crypto-config/tls-cert.pem  -M /crypto-config/ordererOrganizations/orderer/orderer1/tls  --csr.names=${SUBJECT}
```


## Updating the consenter list in the channels

### Updating consenter in system channel


```bash
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/orderer/Admin@example/msp                #path to new Orderer Admin MSP certificates

export CORE_PEER_ADDRESS=orderer1.example.com:7050

export CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER_CA}		   # Orderer CA's tls cert

export CORE_PEER_LOCALMSPID=OrdererMSP                     # Orderer org MSP ID


peer channel fetch config syschannel.pb -c syschannel -o $CORE_PEER_ADDRESS --tls --cafile ${ORDERER_CA}  --tlsHandshakeTimeShift 500h

configtxlator proto_decode --input syschannel.pb --type common.Block | jq .data.data[0].payload.data.config >config.json

cp config.json modified_config.json
```


### Update the Orderer TLS certificate in consenter list (client_tls_cert, server_tls_cert) in modified_config.json


```
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id syschannel --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json


echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"syschannel\", \"type\":2}},\"data\":{\"config_update\":"$(cat config_update.json)"}}}" | jq . >config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb


peer channel update -f config_update_in_envelope.pb -c syschannel -o $CORE_PEER_ADDRESS --tls true --cafile $ORDERER_CA --tlsHandshakeTimeShift 1000h]]></ac:plain-text-body>

```

### Updating consenter in application channel

```bash
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/orderer/Admin@example/msp

export CORE_PEER_ADDRESS=orderer1.example.com:7050

export CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER_CA}

export CORE_PEER_LOCALMSPID=OrdererMSP

peer channel fetch config can.pb -c can -o $CORE_PEER_ADDRESS --tls --cafile ${ORDERER_CA}  --tlsHandshakeTimeShift 1000h

configtxlator proto_decode --input can.pb --type common.Block | jq .data.data[0].payload.data.config >config.json


cp config.json modified_config.json

```

### Update the Orderer TLS certificate in consenter list (client_tls_cert, server_tls_cert) in modified_config.json


```
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id can --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"can\", \"type\":2}},\"data\":{\"config_update\":"$(cat config_update.json)"}}}" | jq . >config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb


peer channel update -f config_update_in_envelope.pb -c can -o $CORE_PEER_ADDRESS --tls true --cafile $ORDERER_CA --tlsHandshakeTimeShift 1000h
```

- Replace the older certs with newer ones in the directory.

- Restart the orderer

- Repeat the same process for all the orderer and for all channels.


