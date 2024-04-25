//合约从用户处获得资金
//然后可以提取资金
//同时设置一个以为美元计价的最小资助额

//SPDX-License-Identifier:Mit
pragma solidity >=0.8.24;

import "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MININUM_USD = 50 * 1e18;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner() {
        //require(msg.sender == i_owner,"sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // 用户通过该函数向合约转账资助
    function fund() public payable {
        //设置一个以usd计算的最小金额
        //1.如何向这个合约转ETH？
        // 确保转账金额达到最小资助额
        //msg.value：这是 Solidity 中的一个特殊变量，表示调用函数时发送的以太币（以 wei 为单位）的数量
        require(
            msg.value.getconversionrate(s_priceFeed) >= MININUM_USD,
            "you need to spend more eth"
        ); //1e18 == 1*10 **==1000000000000000000

        // 记录资助者地址和资助金额
        //msg.sender 是 Solidity 中一个特殊的全局变量，表示当前调用合约的用户地址
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    //withdraw 合约的拥有者（owner）可以提取不同的funder发送的资金
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool callSusses, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSusses, "call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

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
