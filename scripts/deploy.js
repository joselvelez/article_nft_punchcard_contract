async function Main() {
    const contractFactory = await hre.ethers.getContractFactory('ArticlePunchcard');
    const contract = await contractFactory.deploy();

    await contract.deployed();
    console.log("Article Punchcard NFT Contract has deployed to ", contract.address);
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