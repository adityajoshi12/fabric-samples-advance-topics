#!/bin/bash

rm rca.key ca-cert.pem
openssl ecparam -name prime256v1 -genkey -noout -out rca.key

openssl req -new -x509 -sha256 -key rca.key -out ca-cert.pem -days 3650 -subj "/C=IN/ST=Delhi/L=Delhi/O=org1/CN=org1-rootca" -config config.conf -extensions v3_ca

openssl req -new -x509 -sha256 -key rca.key -out tls-cert.pem -days 3650 -subj "/C=IN/ST=Delhi/L=Delhi/O=org1/CN=org1-rootca" -config config.conf -extensions v3_ca_tls


cp ca-cert.pem organizations/fabric-ca/org1/ca-cert.pem
cp rca.key organizations/fabric-ca/org1/rca.key


./network.sh up createChannel -ca -c testchannel
