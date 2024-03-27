
const { Wallets, HsmX509Provider, Gateway } = require("fabric-network");
const fs = require('fs')
const FabricCAClient = require("fabric-ca-client");

const {
    buildCCPOrg1,
} = require("../../test-application/javascript/AppUtil.js");
const ccp = buildCCPOrg1();

const HSM_PROVIDER = 'HSM-X.509';
const adminUserId = `admin`;
const adminUserPw = 'adminpw'


function getHSMLibPath() {
    const pathnames = [
        '/usr/lib/softhsm/libsofthsm2.so', // Ubuntu
        '/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so', // Ubuntu  apt-get install
        '/usr/lib/s390x-linux-gnu/softhsm/libsofthsm2.so', // Ubuntu
        '/usr/local/lib/softhsm/libsofthsm2.so', // Ubuntu, OSX (tar ball install)
        '/usr/lib/powerpc64le-linux-gnu/softhsm/libsofthsm2.so', // Power (can't test this)
        '/usr/lib/libacsp-pkcs11.so', // LinuxOne
        '/opt/homebrew/lib/softhsm/libsofthsm2.so' // OSX
    ];
    let pkcsLibPath = 'NOT FOUND';
    if (typeof process.env.PKCS11_LIB === 'string' && process.env.PKCS11_LIB !== '') {
        pkcsLibPath = process.env.PKCS11_LIB;
    } else {
        //
        // Check common locations for PKCS library
        //
        for (let i = 0; i < pathnames.length; i++) {
            if (fs.existsSync(pathnames[i])) {
                pkcsLibPath = pathnames[i];
                break;
            }
        }
    }

    return pkcsLibPath;
}


const hsmProviderOptions = {
    lib: getHSMLibPath(),
    pin: process.env.PKCS11_PIN || '98765432',
    label: 'ForFabric'
};



/**
 * Perform an HSM ID setup
 * @param {CommonConnectionProfileHelper} ccp The common connection profile
 * @param {String} orgName the organization name
 * @param {String} userName the user name
 */
async function createHSMUser(ccp, orgName, userName) {
    let wallet = await Wallets.newFileSystemWallet(`wallet/${orgName}`);

    let hsmX509Provider = new HsmX509Provider(hsmProviderOptions);
    wallet.getProviderRegistry().addProvider(hsmX509Provider);


    const org = ccp.organizations[orgName];
    const orgMsp = org.mspid;

    // Setup the CAs and providers
    const caName = ccp.certificateAuthorities["ca.org1.example.com"].caName;
    const fabricCAEndpoint = ccp.certificateAuthorities["ca.org1.example.com"].url;
    const tlsOptions = {
        trustedRoots: [],
        verify: false
    };
    const hsmCAClient = new FabricCAClient(fabricCAEndpoint, tlsOptions, caName, hsmX509Provider.getCryptoSuite());


    // first setup the admin user

    if (!await wallet.get(adminUserId)) {

        const adminOptions = {
            enrollmentID: adminUserId,
            enrollmentSecret: adminUserPw
        };
        const adminEnrollment = await hsmCAClient.enroll(adminOptions);
        const adminUserIdentity = {
            credentials: {
                certificate: adminEnrollment.certificate
            },
            mspId: orgMsp,
            type: HSM_PROVIDER
        };
        await wallet.put(adminUserId, adminUserIdentity);

    }
    const adminUserIdentity = await wallet.get(adminUserId);

    const adminUserContext = await hsmX509Provider.getUserContext(adminUserIdentity, adminUserId);

    if (!await wallet.get(userName)) {

        // register the new user using the admin
        const registerRequest = {
            enrollmentID: userName,
            attrs: [],
            role: 'client'
        };
        const userSecret = await hsmCAClient.register(registerRequest, adminUserContext);

        const options = {
            enrollmentID: userName,
            enrollmentSecret: userSecret
        };
        const enrollment = await hsmCAClient.enroll(options);

        // set the new identity into the wallet
        const newUserIdentity = {
            credentials: {
                certificate: enrollment.certificate
            },
            mspId: orgMsp,
            type: HSM_PROVIDER
        };
        await wallet.put(userName, newUserIdentity);
        console.log(`Adding HSM identity for ${userName} to wallet`);
    } else {
        console.log(`${userName} aleady exist in wallet`)
    }

    sendTransaction(wallet, userName)
}


async function sendTransaction(wallet, user){

    const channelName = envOrDefault('CHANNEL_NAME', 'testchannel');
    const chaincodeName = envOrDefault('CHAINCODE_NAME', 'basic');
    const gateway = new Gateway();
    await gateway.connect(ccp, {
        wallet,
        identity: user,
        discovery: { enabled: true, asLocalhost: true } 
    });

    const network = await gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);
    const assetId = Math.random()*1000

    await contract.submitTransaction(
        'CreateAsset',
        assetId,
        'yellow',
        '5',
        'Tom',
        '1300',
    );

    console.log('*** Transaction committed successfully');

}

/**
 * envOrDefault() will return the value of an environment variable, or a default value if the variable is undefined.
 */
function envOrDefault(key, defaultValue) {
    return process.env[key] || defaultValue;
}



createHSMUser(ccp, "Org1","aditya")


