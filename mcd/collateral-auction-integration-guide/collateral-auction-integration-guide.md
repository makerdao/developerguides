# Collateral Auction Integration Guide

## **Overview**

In this guide, you’ll learn how to monitor the state of, begin and participate with LIQ2.0 Collateral Auctions.

This guide is intended to help integrators transition from LIQ1.2 to LIQ2.0 and streamline the integration experience for partners.

## **Learning objectives**

After going through this guide, you will gain a better understanding of:

- How to monitor the state of LIQ2.0 collateral auctions
- How to interact with LIQ2.0 collateral auctions

## **Pre-requisites**

- [Maker Protocol 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md)
- [LIQ2.0 Documentation](https://forum.makerdao.com/t/mip45-liquidations-2-0-liq-2-0-liquidation-system-redesign/6352)
- [Contract addresses](https://www.notion.so/LIQ-2-0-MCD-Kovan-test-deployment-37c507df187e45b1b3fb01ca59a39ddc) (Kovan testnet)

## **Guide**

## Introduction

Auctions play an important role in the Maker Protocol. The three types are clearly described in [the Maker Protocol Docs portal](https://docs.makerdao.com/auctions/the-auctions-of-the-maker-protocol), but the one relevant to this guide is the Collateral Auction:

> The system protects against debt creation by overcollateralization. Under ideal circumstances and with the right risk parameters, the debt for an individual Vault can be covered by the collateral deposited in that Vault. If the price of that collateral drops to the point where a Vault no longer sustains the required collateralization ratio, then the system permits liquidation of the Vault, selling off the collateral to satisfy the outstanding debt and fees in the Vault (and a liquidation penalty). This is done through a **Collateral Auction**.

[MIP 45](https://forum.makerdao.com/t/mip45-liquidations-2-0-liq-2-0-liquidation-system-redesign/6352) proposes a Liquidation System Redesign, dubbed LIQ2.0, that takes the form of a Dutch Auction, in which a high starting price is set, and then decreases deterministically over time. It carries many benefits over the former English auction design, such as Single Block Composability and Protection from Low Prices.

Note: Mainnet addresses to contracts mentioned below can be found in the [latest release](https://changelog.makerdao.com/releases/mainnet/active/) of the Maker Protocol. To see the contract solidity code, go to etherscan.io, click on the `Contract` tab, and finally select the `Code` card. When reading numeric values, remember to account for their magnitudes. Of the fixed point integers:

- `wad` - 18 decimal places
- `ray` - 27 decimal places
- `rad` - 45 decimal places

## High Level Architecture

The [Dog Contract](https://github.com/makerdao/dss/blob/liq-2.0/src/dog.sol) is the public interface for liquidating undercollateralized Vaults and processing  collateral through their respective collateral auction contract (also known as the collateral’s Clipper Contract). There is a single Dog Contract in the Maker Protocol.

Each collateral type has a unique [Clipper contract](https://github.com/makerdao/dss/blob/liq-2.0/src/clip.sol), which owns the collateral on auction, accepts Dai bids, houses the state of all current and former auctions, and holds the logic for auction commencement and participation.

To determine the price of a given auction, the Clipper reads a unique [Abacus contract](https://github.com/makerdao/dss/blob/liq-2.0/src/abaci.sol), which stores and uses a price decrease function, such as one for Linear Decrease or Stair Step Exponential Decrease, to determine the current price of an auction. If there are N clipper contracts, there are N Abaci Contracts in the Maker Protocol.

## Monitoring

### Collateral Risk Parameters

Every Collateral Type (ilk) has risk parameters that define its associated `Clipper` contract, the Liquidation Penalty (chop), the maximum amount of Dai being raised in auction (hole), and the current amount of Dai being raised in auction (dirt). As will be described in the Interaction Section, the `hole` and `dirt` will need to be checked before starting an auction.

The state of a particular `Ilk` can be found through the `ilks` mapping in the `Dog` contract:

```jsx
struct Ilk {
	address clip;  // Liquidator
	uint256 chop;  // Liquidation Penalty                                          [wad]
	uint256 hole;  // Max DAI needed to cover debt+fees of active auctions per ilk [rad]
	uint256 dirt;  // Amt DAI needed to cover debt+fees of active auctions per ilk [rad]
}
```

```jsx
mapping (bytes32 => Ilk) public ilks;
```

### Auction State

Every Auction state is stored in the `Sale` data structure in the collateral’s `Clipper`:

```jsx
struct Sale {
	uint256 pos;  // Index in active array
	uint256 tab;  // Dai to raise       [rad]
	uint256 lot;  // collateral to sell [wad]
	address usr;  // Liquidated CDP
	uint96  tic;  // Auction start time
	uint256 top;  // Starting price     [ray]
}
```

The state of a particular `Sale` can be found through the `sales` mapping:

```jsx
mapping(uint256 => Sale) public sales;
```

On the mapping, the first argument is Auction ID, which is assigned to an auction once it starts. If you’d like to read the current price of the auction, simply pass in the Auction ID to the  `price()` function in the respective Abacus Contract, and it’ll return the DAI price of the collateral, denominated in `ray` (27 decimal places). `Top` is the initial price of the auction, which can be read in the `sale` struct, and `dur` is the amount of seconds since the auction started.

```jsx
function price(uint256 top, uint256 dur) override external view returns (uint256)
```

With the Auction ID, you can query the `Sale` struct in the Clipper contract, locate the respective Abacus contract (called `Clipper.calc()`), and read the `Abacus.price()` function to read the state and price for any auction in question, current or former.

The amount of total auctions within a given `Clipper` can be found by reading the `kicks` variable. This is an integer counter that increases by one every time there’s a new auction.

For users interested in the present state of liquidations, the `Clipper` offers an `active` array that holds a list of live auction IDs. To return an auction id based on position in the active array, call `Clipper.getId(uint256 pos)`, and to return the size of the array, call `Clipper.count()`.

### Auction Activity

Auction activity is simple to track. The `Take` event logs are emitted when an auction starts, and the `Take` event logs are emitted when part of or an entire auction is settled. Moreover, an auction participant can participate in partial bids, where a Dai bid can be under the `tab` and is returned with an amount of collateral, as determined by the auction’s current price.

Therefore, there could be multiple `Take` events for a single Vault (`usr`) and multiple `Take` events for a single auction.

## Interaction

### Starting Auctions

Unsafe Vaults can be liquidated by calling `Dog.bark()` if the following conditions are met:

1. ``` Vault’s CR < Collateral Type’s LR``` When a Vault’s collateralization ratio (CR) dips below the collateral’s liquidation ratio (LR), then it can be liquidated. To calculate the Vault’s CR, follow the [Vault section](https://github.com/makerdao/developerguides/blob/master/vault/monitoring-collateral-types-and-vaults/monitoring-collateral-types-and-vaults.md#vaults) of our Monitoring Collateral Types and Vaults guide. Next, compare it to the LR, which is also described in the aforementioned guide, but for your convenience, it’s stored in the `mat` variable of the `Ilk` struct, within the [Spotter](https://github.com/makerdao/dss/blob/master/src/spot.sol) contract.
2. ``` Unsafe Vault’s USD Debt (i.e. tab) + Dirt <= Hole ```In the `Dog` contract, there’s a Governance controlled parameter `hole` that caps the total amount of Dai being raised in collateral auctions. Moreover, the `Dirt` variable tracks the current amount of Dai out for auction at any given time. Moreover, once the `dirt` fills the `hole`, the `dog` contract can no longer `bark()`, thus pausing liquidations until some Dai is raised and `dirt` is removed from the `hole`. Space left in the hole is defined as `room`.
3. ``` Unsafe Vault’s USD Debt (i.e. tab) + Collateral dirt <= Collateral hole ```

Similarly, there’s a collateral type `hole` that must have `room`. The amount of filling in the hole is defined as `dirt` in the `dog` Contract, and can be queried by calling the `ilks` mapping.

1. The left-over Vault must not be dusty. Dusty is defined by having a smaller leftover `art` than the `ilk.dust`, which is stored in the `vat` contract.

If either of these four conditions are not met, then the transaction will revert. Therefore, we suggest guardrails are put in place to ensure that `dog.bark()` is only called when appropriate.

**Reminder:** It’s imperative that the above comparisons and any calculation is checked when all values hold a common unit. As described in the Introduction section, there are different units used throughout the Maker Protocol, so it’s important to account for the discrepancy in value magnitudes.

As opposed to LIQ1.2, there is no concept of Liquidation Quantity, so only the collateral type’s `hole` constrains the size of the liquidation. For example, if the ETH-A `hole` is 10M Dai and `chop` (Liquidation Penalty) is 10% then an undercollateralized Vault with 9.09M Dai debt can be liquidated, which will kick off a single auction with a 10M Dai `tab` (9.09 * 1.10 ~= 10).

### Participating in Auctions

As introduced in the Monitoring section, to locate a list of live auctions, read the `active` array of active auction IDs by first calling the `count()` to determine the size of the array. Then, for the entire array, call `getId` to read the ID in each element of the array. Then pass in each ID to the `sales` mapping to read the `lot` and the `top` in the `Sale` structure - this is the amount of collateral being sold and the auction starting price, respectively. Finally, read the `calc` (Abacus) variable in the `Clipper` contract to locate the contract that determines the price of any auction associated with said `Clipper` contract. Next, pass in the `top` and the amount of time since the `tic` to the first and second argument, respectively, to the `Calc.price(top, current time - tic)` function to determine the price at which the collateral is being sold for at the `current time`. This section ends with an example that converts this description into a smart contract function.

One of the core benefits of using Dutch Auctions in DeFi is instant settlement. Compared to the former English auction implementation, LIQ2.0 technically removes the concept of a bidder, as anyone that sends DAI to an active auction will be immediately returned an amount of collateral, scaled by the current price.

In other words, LIQ2.0 auctions act like large “ask” offers, as seen in some orderbook exchanges. For example, if an auction is selling 100 ETH, and the price is 200 ETH/DAI, then that can be seen as an “ask”, and anyone with up to 100 * 200 = 20,000 DAI can purchase ETH at that price point. As a result, multiple different participants can partially “fill the order” until the auction is emptied.

Once a user has found a live auction that’s selling a `lot` amount of collateral at a returned price, they can decide how much they’re willing to purchase.

To make this purchase, the user must ensure they have enough Internal Dai in the Vat and the Clipper Contract is approved in the Vat contract to move that internal Dai. Take the following steps:

1. Approve the DaiJoin adapter to take ERC20 Dai of some amount
    1. `ERC20_Dai.approve(DaiJoin address, amount in wad)`
2. Convert ERC20 Dai to Internal Dai
    1. `DaiJoin.join(your address, amount in wad)`
3. Approve the Clipper contract to pull internal Dai from your account
    1. `vat.hope(clipper)`

Note that you’ll need to make three separate transactions, but could avoid this by using a DS-Proxy and a custom proxy library, [similar to this one](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol).

Once internal Dai is in the Vat and approvals have been made, you can call `Clipper.Take()`:

```jsx
function take(
	uint256 id,           // Auction id
	uint256 amt,          // Upper limit on amount of collateral to buy  [wad]
	uint256 max,          // Maximum acceptable price (DAI / collateral) [ray]
	address who,          // Receiver of collateral and external call address
	bytes calldata data   // Data to pass in external call; if length 0, no call is done
) external lock isStopped(2) {...}
```

The `who` and `data` are for advanced use cases where flash loans are employed. These are not covered in our guide but can be understood through the [README of the exchange-callee repo](https://github.com/makerdao/exchange-callees) and [by example](https://github.com/makerdao/exchange-callees/blob/master/src/OasisDexCallee.t.sol#L242-L255) its unit tests. An `exchange-callee` contract is used to facilitate a LIQ2.0 flash loan through a DEX, such as OasisDEX or UniswapV2.

Using the previous example of 100 ETH being sold at 200 ETH/DAI, let’s walk through an example of a User `take`ing 50 ETH from the auction. Note that this smart contract function would be part of a proxy actions library, similar to [Dss-Proxy-Actions](https://github.com/makerdao/dss-proxy-actions), and it assumes that the contract holds an internal Dai balance and has previously approved the Clipper to `vat.move()` its internal Dai. If `clip.take()` is successful, the collateral is sent to the Contract, which will need to be retrieved through another custom function that you have access to (i.e. `auth` to).

**Disclaimer: This function has not been tested in a production environment.**

```jsx
function take_from_last_auction(uint256 maxPrice, uint256 collateralAmount, bytes32 ilk) external auth {
	Address clip = ClipperLike(clipAddress);
	uint count = clip.count();
	uint lastActiveAuction = clip.active(count-1)
	uint lastActiveAuctionId = clip.getId(lastActiveAuction)
	(pos, tab, lot, usr, tic, top) = clip.sales(lastActiveAuctionId);
	address calc = clip.calc();
	uint256 price = calc.price(top, sub(block.timestamp, tic));
	require( price <= maxPrice, “Auction too expensive for me”)
	clip.take(lastActiveAuctionId, collateralAmount, price, msg.sender, “”)
}

Calls take_from_last_auction(ray(200 ether), 50 ether, bytes32(“ETH-A”))
```

The ray() [function is defined here](https://github.com/makerdao/dss/blob/liq-2.0/src/test/clip.t.sol#L321) and should be reused.

### Miscellaneous

There is a case where auctions need to be reset, which would block attempts to `take` from the auction. This will be an unlikely circumstance, but if the time arises, the `Clipper.redo()` function will be called by sophisticated actors, such as DAO Domain teams and Keeper operators. For more information, check out the `MIP45c14 Resetting an Auction` section of [MIP 45](https://forum.makerdao.com/t/mip45-liquidations-2-0-liq-2-0-liquidation-system-redesign/6352).

## **Summary**

In this guide, you learned how to monitor the state of, begin and participate in LIQ2.0 Collateral Auctions.

## **Troubleshooting**

Run into an issue that’s not covered in this guide? Please find our contact information at the end of this guide, and we’ll add it above or to this section.

## **Resources**

Rocket Chat: chat.makerdao.com/channel/dev
