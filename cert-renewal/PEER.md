# Renewing the Peer Certificates

## Renew Signing Certificates
```
fabric-ca-client enroll -u https://PEER_ID:PEER_PW@CA_HOST:7054 -M ${PWD}/peerOrganizations/example.com/peers/PEER_ID/msp --csr.hosts PEER_ID --csr.hosts localhost --tls.certfiles /crypto-config/tls-cert.pem
```


## Renew TLS Certificates
```
fabric-ca-client enroll -d --enrollment.profile tls -u https://PEER_ID:PEER_PWD@CA_HOST:7054 -M ${FABRIC_CA_CLIENT_HOME}/peers/PEER_ID/tls --csr.hosts PEER_ID --csr.hosts localhost --tls.certfiles /crypto-config/tls-cert.pem
```


## Admin Certificates
```
fabric-ca-client enroll -u https://ADMIN_ID:ADMIN_PW@CA_HOST:7054 -M ${PWD}/peerOrganizations/MSP_ID/ADMIN_ID/msp --tls.certfiles /crypto-config/tls-cert.pem
```

- Replace the new certs with old one in the filesystem
- Restart the peer service


