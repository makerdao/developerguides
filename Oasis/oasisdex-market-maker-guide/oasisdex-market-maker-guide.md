# OasisDEX Market Maker Guide

**Level:** Intermediate  
**Estimated Time:** 20 minutes

- [OasisDEX Market Maker Guide](#oasisdex-market-maker-guide)
  - [Overview](#overview)
  - [Learning objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Market Makers](#market-makers)
    - [Web3 interface libraries](#web3-interface-libraries)
  - [Summary](#summary)
  - [Additional Resources](#additional-resources)

## Overview

Having strong liquidity is of paramount importance to any market. This applies to OasisDEX Protocol as well. As OasisDEX is a decentralized protocol, anyone can tap into it to exchange their assets and market make.  
Given the high gas price associated with the cost of cancelling orders, Market Makers sometimes place more than one order (with different prices) on each side of the order book. This way, when the market moves, they don't need to create new orders as they are already there. This strategy also increases the chances of a fill with a bigger spread if Taker brings significant trade to the market.

## Learning objectives

In this guide you will learn how to become a market maker in the OasisDEX protocol by understanding which functions to use in the OasisDEX smart contracts.

## Pre-requisites

You will need a [high level understanding of the OasisDEX Protocol](https://oasisdex.com/docs/guides/introduction#high-level-overview)

## Market Makers

A market maker is a type of user that adds liquidity to a market. They set buy and sell limit orders around a given market, with intention to sell assets higher than their purchase price. Their trades are not executed immediately, but rather their offers live on the order book until a market taker fills them.

The OasisDEX protocol uses a so-called escrow model for market makers. The escrow model simply means that a given asset is locked within the contract when a new order is placed. The asset remains under the sole control of the maker until it is filled. Although such an approach locks down the liquidity, it guarantees a zero counterparty risk and instantaneous settlement.

If Market Makers rely on their orders to be placed on the order book, they should make sure that the order is priced so that it does not fill some other orders.

There are two potential strategies: onchain and offchain. With the onchain strategy Market Maker might check the price of the best offer on both sides and set the price so that there is guarantee that the order will not cross. The offchain strategy is a little more complex as the market maker needs to check the current price offchain, and, when offer() is called, there is a risk that price will move and the offer will actually take order from other market maker. The on-chain strategy has additional advantage of potentially using gas tokens - with offchain market making bot this would need to be handled separately (i.e. gas tokens would need to be bought/sold in a different process).

- **offer()** - Through this function you set the offer for the tokens that you are willing to exchange.
- **cancel()** - Through this function you cancel any offer that you previously made.

**offer()** function structure:

```solidity
function offer(
        uint pay_amt,    //maker (ask) sell how much
        ERC20 pay_gem,   //maker (ask) sell which token
        uint buy_amt,    //maker (ask) buy how much
        ERC20 buy_gem,   //maker (ask) buy which token
        uint pos,        //position to insert offer, 0 should be used if unknown
        bool rounding    //match "close enough" orders?
    )
        public
        can_offer
        returns (uint)
    {
        require(!locked, "Reentrancy attempt");
        require(_dust[address(pay_gem)] <= pay_amt);

        if (matchingEnabled) {
          return _matcho(pay_amt, pay_gem, buy_amt, buy_gem, pos, rounding);
        }
        return super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
    }
```

The first four parameters define:

- **pay_amt:** amount of tokens you are willing to sell
- **pay_gem:** token contract address of the token you are willing to sell
- **buy_amt:** amount of tokens you are willing to buy
- **buy_gem:** token contract address of the token you are willing to buy

The last two parameters define:

- **pos:** sets the position in the order book. Each order has an numbered ID, as an offeror, you can decide where to place your order in the order book. If you want your order automatically placed, set the pos value to 0.
- **rounding:** This parameter tells the matching engine to match your order with a close enough taker. By default this value is set to true. If you are willing to only accept your offer, then set the value to false.

**NOTE:** As of this writing, in the [current OasisDEX deployment](https://etherscan.io/address/0x794e6e91555438aFc3ccF1c5076A74F42133d08D#code), there are multiple `offer()` functions that only differ in the amount of parameters they take. **The recommended `offer()` function to call is the aforementioned one that has the additional `pos` parameter.**

**cancel()** function structure:

```solidity
    // Cancel an offer. Refunds offer maker.
    function cancel(uint id)
        public
        can_cancel(id)
        returns (bool success)
    {
        require(!locked, "Reentrancy attempt");
        if (matchingEnabled) {
            if (isOfferSorted(id)) {
                require(_unsort(id));
            } else {
                require(_hide(id));
            }
        }
        return super.cancel(id);    //delete the offer.
    }
```

The only parameter that this function takes, is the `id` parameter. The id is the identifier of an offer (order) in the order book.

Market Makers cancel orders to reuse liquidity when the market moves and maintain the spread. Since creating orders and cancelling is expensive, some market makers place many orders on each side of the order book so, when the market moves, the next order is already placed and there is no need for the market maker to constantly update the order book.

The ID parameter can be extracted from the set of events that are emitted when the `offer` function is submitted on the blockchain. [Here is an example of an offer transaction and its emitted events.](https://kovan.etherscan.io/tx/0xd7104df4a62b550b3708f31762645c240a64e9e914813458df3b26c9b0ae4839#eventlog)

### Web3 interface libraries

There are a number of web3 interface libraries specific for your technology stack that could help you interact with the OasisDEX protocol:

- Using JavaScript:
  - [https://web3js.readthedocs.io/en/v1.2.9/](https://web3js.readthedocs.io/en/v1.2.9/)
  - [https://docs.ethers.io/v5/](https://docs.ethers.io/v5/)
- Using Java
  - [https://github.com/web3j/web3j](https://github.com/web3j/web3j)
- Using Python
  - [https://web3py.readthedocs.io/en/stable/](https://web3py.readthedocs.io/en/stable/)
  - [Pymaker](https://github.com/makerdao/pymaker/blob/master/pymaker/oasis.py) - a library by Maker covering Maker Protocol contracts including OasisDEX
- .NET
  - [https://nethereum.com/](https://nethereum.com/)

## Summary

In this guide, you have learned how to integrate with OasisDEX protocol as a market maker by calling the above mentioned functions in the matching contracts.

## Additional Resources

- [Intro do OasisDEX protocol](https://oasisdex.com/docs/guides/introduction)
- [How to use Oasis Direct Proxy on OasisDEX protocol](https://oasisdex.com/docs/guides/use-proxy)
