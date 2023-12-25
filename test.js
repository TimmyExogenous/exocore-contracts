const { ethers, JsonRpcProvider } = require("ethers");

const provider = new JsonRpcProvider("http://127.0.0.1:8545");

var signer = new ethers.Wallet("0x8DD855BC33B90120375F7505044EDF5D197C8561630E262D27CBB98DBC4DAF76", provider);
var deposit_raw_data = "0x58bd9b810000000000000000000000000000000000000000000000000000000000000065000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000004d20000000000000000000000000000000000000000000000000000000000000020dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000";
var withdraw_raw_data = "0xcfcd22690000000000000000000000000000000000000000000000000000000000000065000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000000020dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000";
var delegate_raw_data = "0xedc32d0a0000000000000000000000000000000000000000000000000000000000000065000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000000020dac17f958d2ee523a2206206994597c13d831ec700000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c65766d6f73317a647a6b7479666e366d72717070787337336c376b686a35363865636d393772636d6174397a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
var undelegate_raw_data = "0x81d278420000000000000000000000000000000000000000000000000000000000000065000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000630000000000000000000000000000000000000000000000000000000000000020dac17f958d2ee523a2206206994597c13d831ec700000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c65766d6f73317a647a6b7479666e366d72717070787337336c376b686a35363865636d393772636d6174397a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

provider.getBlockNumber().then(console.log);
console.log(signer.address);

(async () => {
    var deposit_tx = await signer.sendTransaction({
        to: "0x0000000000000000000000000000000000000804",
        value: 0,
        data: deposit_raw_data
    });
    console.log("deposit tx: ", deposit_tx);
    await new Promise(resolve => setTimeout(resolve, 5000));
    var deposit_tx_receipt = await provider.getTransactionReceipt(deposit_tx.hash);
    console.log("deposit tx receipt:", deposit_tx_receipt);

    var withdraw_tx = await signer.sendTransaction({
        to: "0x0000000000000000000000000000000000000808",
        value: 0,
        data: withdraw_raw_data
    });
    console.log("withdraw tx:", withdraw_tx);
    await new Promise(resolve => setTimeout(resolve, 5000));
    var withdraw_tx_receipt = await provider.getTransactionReceipt(withdraw_tx.hash);
    console.log("withdraw tx receipt:", withdraw_tx_receipt);
})();

