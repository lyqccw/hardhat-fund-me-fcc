//SPDX-License-Identifier:Mit
pragma solidity >=0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
library PriceConverter {
    //获取 ETH/USD 的当前价格
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //调用 latestRoundData() 获取最新价格数据
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //这个价格是ETH相对于USD的
        return uint256(answer * 1e10);
    }

    //获取 Chainlink Aggregator 版本信息
    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    // 根据给定的 ETH 金额计算其相对于 USD 的价值
    function getconversionrate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethprice = getPrice(priceFeed);
        uint256 ethAmountUsd = (ethprice * ethAmount) / 1e18;
        return ethAmountUsd;
    }
}
