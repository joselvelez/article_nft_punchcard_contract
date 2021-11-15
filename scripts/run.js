const { ethers } = require("ethers");

async function Main() {
    const contractFactory = await hre.ethers.getContractFactory('ArticlePunchcard');
    const contract = await contractFactory.deploy();

    await contract.deployed();
    console.log("Article Punchcard NFT Contract has deployed to ", contract.address);

    let txn;

    // get current price
    console.log("Get current price");
    txn = await contract.getRedemptionCost();
    console.log(parseInt(txn));

    // Set new price
    console.log("Set new price");
    txn = await contract.setRedemptionCost(15000000000);
    await txn.wait();

    // get new price
    console.log("Get current price");
    txn = await contract.getRedemptionCost();
    console.log(parseInt(txn));

    // check if address has a punchcard
    console.log("Checking to see if address has a punchcard, should be false");
    txn = await contract.getPunchcard();
    console.log(txn);

    // Mint a punch card
    console.log("Attempting to purchase a punchcard");
    txn = await contract.purchasePunchcard(8, { value: ethers.utils.parseEther("0.00000012") });

    // check if address has a punchcard
    console.log("Checking to see if address has a punchcard, should be true");
    txn = await contract.getPunchcard();
    console.log(txn);

    // get balance
    console.log("Get current balance");
    txn = await contract.getBalance(1);
    console.log(parseInt(txn));

    // add to balance
    console.log("Add to balance");
    txn = await contract.addRedemptions(3, 1, {value: ethers.utils.parseEther("0.000000045")});
    txn = await contract.getBalance(1);
    console.log("New balance is %s", parseInt(txn));

    // check if address has access to this article
    console.log("Check if can access article");
    txn = await contract.accessToArticle(1);
    console.log(txn);

    // assign article 1 to test address
    console.log("Purchasing article 1");
    txn = await contract.assignAccessToArticle(1);

    // check if address has access to article 1
    console.log("Check if can access article 1");
    txn = await contract.accessToArticle(1);
    console.log(txn);

    // check if address balance is decremented by 1
    console.log("New balance after buying access to article 1");
    txn = await contract.getBalance(1);
    console.log("New balance is %s", parseInt(txn));
}

async function runMain() {
    try {
        await Main();
        process.exit(0);
    } catch (e) {
        console.log(e);
        process.exit(1);
    }
}

runMain();