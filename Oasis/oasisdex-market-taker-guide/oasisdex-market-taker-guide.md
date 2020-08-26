# OasisDEX Market Taker Guide

**Level:** Intermediate  
**Estimated Time:** 45 minutes

- [OasisDEX Market Taker Guide](#oasisdex-market-taker-guide)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Guide](#guide)
  - [Current Deployment](#current-deployment)
  - [Fill or Kill orders](#fill-or-kill-orders)
  - [Support methods](#support-methods)
  - [Oasis Proxy Actions](#oasis-proxy-actions)
  - [Summary](#summary)

## Overview

There are many approaches to integrate the OasisDEX Protocol into your system. Each approach has pros and cons, varying levels of complexity, and different technical requirements. This guide is purposed to help streamline the integration experience for Market Takers, which include but are not limited to DEX Aggregators, Wallets, and Trading Bots.

## Learning Objectives

- Understand the role of a Market Taker
- Learn about ways to read the effective spot prices and orderbooks on OasisDEX
- Learn how to execute Fill-or-Kill orders on OasisDEX

## Pre-requisites

You will need a [high level understanding of the OasisDEX Protocol](https://oasisdex.com/docs/guides/introduction#high-level-overview)

## Guide

A market taker is a type of user that takes liquidity from a market. Their action to trade with the highest bid or lowest ask is a signal of their content with current asset price; in other words, they are willing to trade assets at the present levels and are wishing to fill an existing order. A market maker, the other type of market participant, is described in the OasisDEX Market Makers Integration Guide.

In this guide, you will learn how to read the state of the OasisDEX order book and publish transactions that fill orders with instant settlement. Let’s begin.

## Current Deployment

Note that anyone can launch their own deployment of the OasisDEX Protocol, which is available as open-source software. The below indicated deployments are the most popular ones at the time of publishing this guide. Make sure that you integrate with the right deployment.

```bash
Mainnet:

-   MatchingMarket - 0x794e6e91555438aFc3ccF1c5076A74F42133d08D
-   MakerOtcSupportMethods - 0x9b3F075b12513afe56Ca2ED838613B7395f57839
-   ProxyRegistry - 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4
-   ProxyCreationandExecute - 0x793EbBe21607e4F04788F89c7a9b97320773Ec59

Kovan:

-   MatchingMarket - 0xe325acB9765b02b8b418199bf9650972299235F4
-   MakerOtcSupportMethods - 0x303f2bf24d98325479932881657f45567b3e47a8
-   ProxyRegistry - 0x64A436ae831C1672AE81F674CAb8B6775df3475C
-   ProxyCreationandExecute - 0xee419971e63734fed782cfe49110b1544ae8a773  
```

## Fill or Kill orders

The OasisDEX Protocol matching engine is fully on-chain. Therefore, the engine will atomically attempt to fill any orders that are sent through `offer()`. If, however, the offer cannot be completely filled, part of the fill attempt will be placed as a bid/ask offer on the OasisDEX orderbook. As a market taker, it is assumed that you want to completely fill or cancel the order; thus, we will be focusing exclusively on Fill-Or-Kill order types.

Fill or Kill order types:

- `function sellAllAmount(ERC20 pay_gem, uint  pay_amt, ERC20 buy_gem, uint  min_fill_amount)`
  - `pay_gem` - address of token to sell
  - `pay_amt` - uint, wad units (i.e. Wei units, 10^18)
  - `buy_gem` - address of token to purchase
  - `min_fill_amount` - uint, wad units (i.e. Wei units, 10^18)
  - attempts to spend all pay tokens to buy specified minimum buy tokens. More tokens may be bought if it is possible. So, for example, when buying 1 ETH for 300 DAI, all 300 DAI will be spent and possibly 1.034 ETH will be bought if the current market price is 290. Transaction reverts if more than 300 DAI would have to be spent to buy 1 ETH
- `function buyAllAmount(ERC20 buy_gem, uint  buy_amt, ERC20 pay_gem, uint  max_fill_amount)`
  - `buy_gem` - address of token to sell
  - `buy_amt` - uint, wad units (i.e. Wei units, 10^18)
  - `pay_gem` - address of token to purchase
  - `max_fill_amount` - uint, wad units (i.e. Wei units, 10^18)
  - attempts to buy a specified amount of buy tokens for a specified amount of pay tokens up to a certain price. So, for example, when buying 1 ETH for 300 DAI, possibly only 290 DAI will be spent if the current market price is 290. Transaction reverts if more than 300 DAI would have to be spent to buy 1 ETH, similarly to sellAllAmount().
- `function getBuyAmount(ERC20 buy_gem, ERC20 pay_gem, uint  pay_amt)`
  - `buy_gem` - address of token to sell
  - `pay_gem` - address of token to purchase
  - `pay_amt` - uint, wad units (i.e. Wei units, 10^18)
  - returns how much of `buy_gem` can be bought by paying `pay_amt` of `pay_gem` (effective spot price)
- `function getPayAmount(ERC20 pay_gem, ERC20 buy_gem, uint  buy_amt)`
  - `pay_gem` - address of token to purchase
  - `buy_gem` - address of token to sell
  - `buy_amt` - uint, wad units (i.e. Wei units, 10^18)
  - returns how much of `pay_gem` one needs to pay to buy `buy_amt` of `buy_gem` (effective spot price)

Before a Fill-Or-Kill order can be executed, the `msg.sender` or contract executing the subcall must gain awareness of the asset’s price. This will be used in conjunction with a prescribed slippage limit to define a minimum (`min_fill_amount`) or max amount (`max_fill_amount`) to be filled in the trade. The `getBuyAmount( )` and `getPayAmount( )` methods are used to capture the effective spot price of a trade. Since a lot could happen in the order books between publishing a transaction and its confirmation, one needs to set a guardrail to defend against slippage.

## Support methods

There are some integrators that wish to query the entire order book. For example, it could be a DEX front end that wishes to present the state of the orderbook on a UI or a DEX aggregator that wants to calculate the effective spot price off-chain. To support these needs, we offer [MakerOTCSupportMethods.sol](https://github.com/daifoundation/maker-otc-support-methods/blob/master/src/MakerOtcSupportMethods.sol), which is contract that exposes the following getter support method:

- `function getOffers(address otc, address payToken, address buyToken)`
  - `otc` - address of MatchingMarket contract
  - `payToken` - address of token to sell
  - `buyToken` - address of token to purchase
  - Returns the best 100 offers of a given pair

## Oasis Proxy Actions

Integrations that support DSProxies may achieve a few efficiencies, such as bundling order book reads with Fill-Or-Kill calls in single transactions. There exists an Oasis Proxy Action library that is used by some major front-ends. If you’re interested, we recommend going through the [Oasis Proxy Actions guide](https://oasisdex.com/docs/guides/use-proxy) before continuing.

Use of a Proxy Action library in conjunction with one’s DSProxy eliminates Fill-Or-Kill orders made with stale order book data, which could result in reverted transactions. Other advantages include deploying new proxies and executing Fill-or-Kill orders at once, as well as executing Fill-or-Kill orders and exiting into native ETH at once; without the last proxy action, users are required to submit an extra transaction that unwraps their WETH, which adds friction to the user experience and is slightly more gas intensive.

Although the aforementioned efficiencies are captured with the use of DSProxies, the management thereof needs to be considered in the evaluation of such an integration. More information can be found in the [Working with DSProxy Guide](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md).

Misc Comments / Reminders

- Remember to approve the OasisDEX / your DSProxy contract to move your tokens before interaction
- Advanced Market Takers (bots, etc) that are looking to save gas would be interested in [Cherry-picking offers from the order book](https://oasisdex.com/docs/guides/introduction#cherry-picking-an-offer-from-the-order-book).

Example Integrations (all w/o Oasis Proxy Actions, but still likely using a custom proxy library)

- Dydx.exchange
  - [Effective spot price read](https://github.com/dydxprotocol/exchange-wrappers/blob/master/contracts/exchange-wrappers/OasisV3MatchingExchangeWrapper.sol#L102)

```solidity
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256)
    {
        IMatchingMarketV1 market = MATCHING_MARKET;

        // Must add 1 to the maker and taker amounts due to rounding differences in OasisDEX when
        // calling the "pay" functions vs the "buy" functions. This will lock some tokens in this
        // contract, but the value will be less than the sum of the smallest unit of each token.
        uint256 costInTakerToken = market.getPayAmount(
            takerToken,
            makerToken,
            desiredMakerToken.add(1)
        ).add(1);

        // validate results, exclusive to dydx (i.e. 128 bits to prevent overflow when checking bounds)

        requireBelowMaximumPrice(costInTakerToken, desiredMakerToken, orderData);

        return costInTakerToken;
    }
```

- [Fill-or-Kill order](https://github.com/dydxprotocol/exchange-wrappers/blob/master/contracts/exchange-wrappers/OasisV3MatchingExchangeWrapper.sol#L69)

```solidity
function exchange(
        address /*tradeOriginator*/,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256)
    {
        IMatchingMarketV1 market = MATCHING_MARKET;

        // make sure that the exchange can take the tokens from this contract
        takerToken.ensureAllowance(address(market), requestedFillAmount);

        // do the exchange
        uint256 receivedMakerAmount = market.sellAllAmount(
            takerToken,
            requestedFillAmount,
            makerToken,
            0
        );

        // validate results
        requireBelowMaximumPrice(requestedFillAmount, receivedMakerAmount, orderData);

        // set allowance for the receiver
        makerToken.ensureAllowance(receiver, receivedMakerAmount);

        return receivedMakerAmount;
    }
```

- Instadapp.io - Note that Eth2Dai was a deprecated front end that supported OasisDEX
  - [Effective spot price read](https://github.com/InstaDApp/smart-contract/blob/master/contracts/ProxyLogics/SplitSwap/SplitSwap.sol#L206)
  - [Fill-or-Kill order](https://github.com/InstaDApp/smart-contract/blob/master/contracts/ProxyLogics/SplitSwap/SplitSwap.sol#L235)
- DeFiSaver
  - [Fill-or-Kill order](https://github.com/DecenterApps/defisaver-contracts/blob/a227c4ae19b9c4d47cac5cc1e1a5872bf3255309/contracts/exchange/wrappers/OasisTradeWrapper.sol#L20)

Other than through Solidity and Web3, as seen in the above integrations, here are other API libraries that can be used to interact with OasisDEX:

- [Pymaker](https://github.com/makerdao/pymaker/blob/master/pymaker/oasis.py)
- [Dai.js](https://docs.makerdao.com/dai.js/single-collateral-dai/exchange-service)

## Summary

In this guide, you have learned how to read the orderbook and execute Fill-or-Kill orders on the OasisDEX protocol.
