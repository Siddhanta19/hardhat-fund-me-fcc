const { assert } = require("chai");
const { ethers, getNamedAccounts, network } = require("hardhat");
const {
	developmentChains: devChainNames,
} = require("../../helper-hardhat-config");

devChainNames.includes(network.name)
	? describe.skip
	: describe("FundMe", function() {
			let fundMe;
			let deployer;
			const sendValue = ethers.utils.parseEther("1");
			beforeEach(async function() {
				deployer = (await getNamedAccounts()).deployer;
				fundMe = await ethers.getContract("FundMe", deployer);
			});

			it("Allows people to fund and withdraw", async function() {
				await fundMe.fund({ value: sendValue });
				await fundMe.withdraw();
				const endingBalance = await fundMe.provider.getBalance(fundMe.address);
				assert.equal(endingBalance.toString(), "0");
			});
	  });
