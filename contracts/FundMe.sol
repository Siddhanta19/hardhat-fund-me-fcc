// SPDX-License-Identifier: MIT
// Pragma
pragma solidity ^0.8.7;
// Imports
// Get Funds from Users
// Withdraw Funds
// Set a minimum funding value in USD

import "./PriceConverter.sol";
import "hardhat/console.sol";

// error codes
error FundMe__NotOwner();

// interfaces, libraries, contracts

/** @title A contract for crowd funding
 * @author Siddhanta Paul
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;
    // 21,393 gas - constant
    // 23,515 gas - non-constant

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;

    uint256 public constant MINIMUM_USD = 10 * 1e18; // 1 * 10 ** 18

    AggregatorV3Interface private s_priceFeed;

    // events, modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not i_owner!");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress) {
        // i_owner = whoever deploys the contract;
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD.
        // 1. How do we send ETH to this contract
        // msg.value.getConversionRate();
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough"
        ); // 1e18 = 1 * 10 ** 18 = 10000000000000000
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
        // What is reverting? -> transaction undone!
        // undo any action b4 and send the remaining gas
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == i_owner, "Sender is not i_owner!");
        uint256 fundersLength = s_funders.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset the array
        s_funders = new address[](0);
        // actually withdraw the funds

        // transfer, send, call

        // msg.sender = address;
        // payable(msg.sender) = payable address;

        payable(msg.sender).transfer(address(this).balance); // transfer

        bool sendSuccess = payable(msg.sender).send(address(this).balance); //send
        require(sendSuccess, "Send Failed!");

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed!");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry...

        uint256 fundersLength = funders.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset the array
        s_funders = new address[](0);
        // actually withdraw the funds

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Call Failed!");
    }

    // What happens if someone sends this contract ETH without calling the fund func
    // fallback()

    /* view/pure functions */

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
