
## HSM
A Hardware Security Module (HSM) is a physical computing device that safeguards and manages digital keys for strong authentication and provides cryptoprocessing. These modules traditionally come in the form of a plug-in card or an external device that attaches directly to a computer or network server.


### SoftHSM
#### Installation

First, we install SoftHSMv2 and configure it to store tokens in the default location `/var/lib/softhsm/tokens`. 
```bash


sudo apt-get install -y softhsm2 opensc # linux

brew install softhsm # macos

cat <<EOF | sudo tee /etc/softhsm/softhsm2.conf
directories.tokendir = /var/lib/softhsm/tokens
objectstore.backend = file
# ERROR, WARNING, INFO, DEBUG
log.level = DEBUG
EOF

sudo mkdir /var/lib/softhsm/tokens
sudo usermod -G softhsm $(whoami)
sudo chmod 0770 /var/lib/softhsm/tokens
echo 'export SOFTHSM2_CONF=/etc/softhsm/softhsm2.conf' | tee -a ~/.bashrc
source ~/.bashrc


```

#### Initalization

Next, we create a token in slot 0 called `ForFabric` and secure it with a PIN of 98765432. 
```bash

# available slots
softhsm2-util --show-slots


# initalize token
softhsm2-util --init-token --slot 1 --label "ForFabric" --pin 98765432 --so-pin 1234
```

#### Client App
```
node hsm.js
```
client app has been test for nodejs version 16.
