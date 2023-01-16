// import
// main function
// calling of main function

/* function deployFunc(hre) {
	console.log("Hi!");
}

module.exports.default = deployFunc; */

const {
	networkConfig,
	developmentChains: devChainNames,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy, log, get } = deployments;
	const { deployer } = await getNamedAccounts();
	const chainId = network.config.chainId;

	// const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
	let ethUsdPriceFeedAddress;
	if (devChainNames.includes(network.name)) {
		const ethUsdAggregator = await get("MockV3Aggregator");
		ethUsdPriceFeedAddress = ethUsdAggregator.address;
	} else {
		ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
	}

	// if the contract doesn't exist, we deploy a minimal version of price feed contract for our local testing

	// what happens when we want to change chains?
	// when going for localhost or hardhat network, we want to use a mock
	const args = [ethUsdPriceFeedAddress];
	const fundMe = await deploy("FundMe", {
		from: deployer,
		args: args, //put price feed address
		log: true,
		waitConfirmations: network.config.blockConfirmations || 1,
	});

	if (!devChainNames.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
		await verify(fundMe.address, args);
	}
	log("------------------------------------------------------------------");
};

module.exports.tags = ["all", "fundme"];