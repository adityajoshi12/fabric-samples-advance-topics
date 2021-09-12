const { Gateway, Wallets } = require("fabric-network");
const FabricCAServices = require("fabric-ca-client");
const path = require("path");
let fs = require("fs");
const { BlockDecoder } = require("fabric-common");
// const helpers = require("./app/helper");
let username = "appUser";

const getCCP = async (org) => {
  let ccpPath = null;
  org == "Org1"
    ? (ccpPath = path.resolve(
        __dirname,

        "connection.json"
      ))
    : null;
  org == "Org2"
    ? (ccpPath = path.resolve(
        __dirname,
        "..",
        "config",
        "connection-org2.json"
      ))
    : null;
  org == "Org3"
    ? (ccpPath = path.resolve(
        __dirname,
        "..",
        "config",
        "connection-org3.json"
      ))
    : null;
  const ccpJSON = fs.readFileSync(ccpPath, "utf8");
  const ccp = JSON.parse(ccpJSON);
  return ccp;
};

async function queryBlock() {
  try {
    let ccp = await getCCP("Org1");
    const walletPath = path.join(process.cwd(), "wallet");
    console.log(walletPath);

    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const gateway = new Gateway();
    await gateway.connect(ccp, {
      wallet,
      identity: username,
      discovery: { enabled: true, asLocalhost: true },
    });

    const network = await gateway.getNetwork("mychannel");

    // Get the contract from the network.
    const contract = network.getContract("qscc");
    // console.log(contract);
    let result = await contract.evaluateTransaction(
      "GetBlockByNumber",
      "mychannel",
      "5"
    );
    result = BlockDecoder.decode(result);
    console.log(result);
  } catch (ex) {
    console.error(ex);
  }
}

queryBlock();
