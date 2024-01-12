# Fabric Advance Topics

This repository contains the advance fabric topics with the link to the details explanation. If you find this repository **, Please Star and Fork this repository** it really gives me motivation to make such content and you can also follow me on [medium](https://adityaajoshi.medium.com/) for such content.

## Roadmap
[Roadmap for Hyperledger Fabric](https://adityaajoshi12.gumroad.com/l/roadmap-hyperledger-fabric) - Use Coupon **LAUNCH-OFFER** and get it for free.

## Content
- [Hyperledger Fabric Blockchain Performance Benchmark Using Hyperleger Capiler](https://adityaajoshi.medium.com/hyperledger-fabric-blockchain-performance-benchmark-using-hyperleger-capiler-66d9a9af5cce)
- [Hyperledger Fabric v2.X Monitoring Using Prometheus](https://medium.com/coinmonks/hyperledger-fabric-v2-x-monitoring-using-prometheus-974e433073f5)
- [Modifying the Batch Size in Hyperledger Fabric v2.2](https://medium.com/coinmonks/modifying-the-batch-size-in-hyperledger-fabric-v2-2-3ec2dd779e2b)
- [Integrating Hyperledger Explorer with Hyperledger Fabric Network v2.2](https://medium.com/coinmonks/integrating-hyperledger-explorer-with-hyperledger-fabric-network-v2-2-9a70e4c5311)
- [Adding a new Orderer in Running Hyperledger Fabric v2.2 Network](https://medium.com/coinmonks/adding-a-new-orderer-in-running-hyperledger-fabric-v2-2-network-4c90c8315ae1)
- [Getting Started - Hyperledger Fabric 2.2 Tutorial](https://adityaajoshi.medium.com/hyperledger-fabric-2-2-tutorial-eb21618d5fa)

- [Renew peers and orderer certificates](./cert-renewal/)



## Courses
<br>

- <img src="https://img-c.udemycdn.com/course/240x135/3741540_d31f_4.jpg" width="100px"/> [Learn to Deploy Hyperledger Fabric v2.2 on Multihost](https://udemy.com/course/learn-to-deploy-hyperledger-fabric-v22-on-multihost/)

- <img src="https://img-c.udemycdn.com/course/240x135/3970920_6f16_4.jpg" width="100px"/> [The Complete Guide on Hyperledger Fabric v2.x on Kubernetes](https://www.udemy.com/course/hyperledger-fabric-on-kubernetes-complete-guide)

- <img src="https://img-c.udemycdn.com/course/240x135/3815532_1edc_2.jpg" width="100px"/> [Master Class On Hyperledger Besu](https://udemy.com/course/hyperledger-besu-master-class)

- <img src="https://img-c.udemycdn.com/course/240x135/3814476_e3c7.jpg" width="100px"/> [Certified Blockchain Developer Certification - 2023](https://www.udemy.com/course/certified-blockchain-developer-certification)
  
- <img src="https://d502jbuhuh9wk.cloudfront.net/courses/6582a990e4b0f762acd78a07/6582a990e4b0f762acd78a07_scaled_cover.jpg" width="100px"/> [Hyperledger Fabric Certified Pracitioner (HFCP) - 2024](https://courses.bytelearn.in/courses/Hyperledger-Fabric-Certified-Practitioner-HFCP-6582a990e4b0f762acd78a07)


## Install cfssl
Linux
```
VERSION=$(curl --silent "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VNUMBER=${VERSION#"v"}
wget https://github.com/cloudflare/cfssl/releases/download/${VERSION}/cfssl_${VNUMBER}_linux_amd64 -O cfssl
chmod +x cfssl
sudo mv cfssl /usr/local/bin
VERSION=$(curl --silent "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VNUMBER=${VERSION#"v"}
wget https://github.com/cloudflare/cfssl/releases/download/${VERSION}/cfssljson_${VNUMBER}_linux_amd64 -O cfssljson
chmod +x cfssljson
sudo mv cfssljson /usr/local/bin
```
MacOS
```
VERSION=$(curl --silent "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VNUMBER=${VERSION#"v"}
wget https://github.com/cloudflare/cfssl/releases/download/${VERSION}/cfssl_${VNUMBER}_darwin_amd64 -O cfssl
chmod +x cfssl
sudo mv cfssl /usr/local/bin

VERSION=$(curl --silent "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VNUMBER=${VERSION#"v"}
wget https://github.com/cloudflare/cfssl/releases/download/${VERSION}/cfssljson_${VNUMBER}_darwin_amd64 -O cfssljson
chmod +x cfssljson
sudo mv cfssljson /usr/local/bin
```

## Setup CLI
```
export PATH=$PWD/../bin/linux:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
source ./scripts/envVar.sh
setGlobals 1
```

## Chaincode invoke
```
peer chaincode invoke -o localhost:7050 --tls true --cafile $ORDERER_CA -C testchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["InitLedger"]}'


peer chaincode query -C testchannel -n basic -c '{"Args":["GetAllAssets"]}'

peer chaincode invoke -o localhost:7050 --tls true --cafile $ORDERER_CA -C testchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["CreateAsset","100","Red","5","Aditya","2000"]}'


peer chaincode invoke -o localhost:7050 --tls true --cafile $ORDERER_CA -C testchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["TransferAsset","100","Nithin"]}'

peer chaincode query -C testchannel -n basic -c '{"Args":["GetAllAssets"]}'
```
