# Introduction to Auctions and Keepers in Multi-Collateral Dai

The Multi-Collateral Dai (MCD) system within the MakerDAO Protocol is a smart contract platform on Ethereum that backs and stabilizes the value of our stablecoin, Dai. It does this through a dynamic system of Collateralized Debt Positions (CDPs), autonomous feedback mechanisms, and appropriately incentivized external actors.

In this document, we explain the auction mechanisms within the system, as well as particular types of external actors, called Keepers, that bid on the Auctions.

## Auctions

When everything in the system is going well, Dai accrues through stability fees collected from CDPs. Whenever the net surplus from stability fees reaches a certain limit, that surplus in Dai is auctioned off to external actors for MKR which subsequently is burnt, thereby reducing the amount of MKR in circulation. This is done through a **Surplus  Auction**.

The system protects against debt creation by overcollateralization. Under ideal circumstances and with the right risk parameters, the debt for an individual CDP can be covered by the collateral deposited in that CDP. If the price of that collateral drops to the point where a CDP no longer sustains the required collateralization ratio, then the system automatically liquidates the CDP and sells off the collateral until the outstanding debt in the CDP (and a liquidation penalty), is covered. This is done through a **Collateral Auction**.

Further, if, for example, the collateral price drops sharply or no one wants to buy the collateral, there may be debt in the liquidated CDP that cannot be repaid through a collateral auction and must be addressed by the system. The first course of action is to cover this debt using surplus from stability fees, if there is any surplus to cover it. If there is not, then the system initiates a **Debt Auction**, whereby the winning bidder pays Dai to cover the outstanding debt and in return receives an amount of newly minted MKR, increasing the amount of MKR in circulation.

To summarize, we have three types of Auctions:
- **Surplus Auction**: The winning bidder pays MKR for surplus Dai from stability fees. The MKR received is burnt, thereby reducing the amount of MKR in circulation.
- **Collateral Auction**: The winning bidder pays Dai for collateral from a liquidated CDP. The Dai received is used to cover the outstanding debt in the liquidated CDP.
- **Debt Auction**: The winning bidder pays Dai for MKR to cover outstanding debt that Collateral Auctions haven’t been able to cover. MKR is minted by the system, thereby increasing the amount of MKR  in circulation.

The actors that bid on these Auctions are called **Keepers**.

## Keepers

With all information published on the Ethereum blockchain, anyone can access or monitor price feeds and data on individual CDPs, thereby determining whether certain CDPs are in breach of the Liquidation Ratio.  The system incentivizes these market participants (which can be human or automated bot), known as “keepers,” to monitor the MCD System and trigger liquidation when the Liquidation Ratio is breached. 

In the context of Multi-Collateral Dai, Keepers may participate in auctions as a result of liquidation events and thereby acquire collateral at attractive prices. Keepers can also perform other functions, including trading Dai motivated by the expected long-term convergence toward the Target Price.

We will now go into more detail about how the **Auctions** work.

## The Auction Parameters and Mechanisms
Various considerations were taken into account when designing the auction mechanisms. For example, from a systems point of view, it’s best to complete the auction as soon as possible to keep the system in a steady state, so the auction mechanism incentivizes early bidders. Another consideration is that the Auctions are executed on-chain, minimizing the number of required transactions and reducing associated fees.

### Auctions Glossary
**Risk parameters**. In general, the following parameters are used across all of the auction types:

- `beg`: Minimum bid increase (for example, 3%).
- `ttl`: Bid duration (for example, 6 hours). The auction ends if no new bid is placed during this time.
- `Tau`: Auction duration (for example, 24 hours). The auction ends after this period under all circumstances.

The values of the risk parameters are determined by Maker Governance voters (MKR holders) per auction type. Note that there are different Collateral Auction risk parameters for each type of collateral used in the system.

**Auction and bid information**. The following information is always available during an active auction:
- `lot` : Amount of asset that is up for auction/sale. 
- `bid`: Current highest bid. 
- `guy`: Highest bidder.
- `tic`: Bid expiry date/time (empty if zero bids).
- `end`: Auction expiry date/time.

## Bid Increments During an Auction

During an auction, bid amounts will increase by a percentage with each new bid. This is the `beg` at work. For example, the `beg` could be set to 3%, meaning if the current bidder has placed a bid of 100 Dai, then the next bid must be at least 103 Dai. Overall, the purpose of the bid increment system is to incentivize early bidding and make the auction process move quickly.

### How Bids are Placed During an Auction

Bidders send DAI or MKR tokens from their addresses to the system/specific auction. If one bid is beat by another, the losing bid is refunded back to that bidder’s address. It’s important to note, however, that once a bid is submitted, there is no way to cancel it. The only possible way to have that bid returned is if it is out-bid. 

Now, let’s review the mechanisms of the three different auction types.


## Surplus Auction
**Summary**: A Surplus Auction is used to auction off a fixed amount of surplus Dai in the system in exchange for MKR. This surplus Dai will generally come from accumulated stability fees. In this auction, bidders compete with increasing bids of MKR. Once the auction has ended, the auctioned Dai is sent to the winning bidder, and the system burns the MKR received from the winning bidder.

**High-level Mechanism Process**:
Maker Governance voters determine the amount of surplus allowed in the system at any one time. A Surplus auction is triggered when the system has a Dai surplus over the pre-determined amount as set by MKR governance.

- To determine whether the system has a net surplus, accrued stability fees and debt in the system must be added together. Any user can do this by sending the `heal` transaction to the system contract called Vow.
- Provided there is a net surplus, the Surplus Auction is triggered when any user sends the flop transaction to the Vow contract.

When the auction begins, a fixed amount (lot) of Dai is put up for sale. Bidders then bid with MKR in increments greater than the minimum bid increase amount. The auction officially ends when the bid duration ends (ttl) without another bid  OR when the auction duration (tau) has been reached. Once the auction ends, the MKR received for the surplus Dai is then sent to be burnt, thereby contracting the system’s MKR supply.


## Collateral Auction (Collateral Sale)
**Summary**: Collateral Auctions serve as a means to recover debt in liquidated CDPs.  Those CDPs are being liquidated because the value of the CDP collateral has fallen below a certain limit determined by the Maker Governance voters.

**High-level Mechanism Process**:
For each type of collateral, MKR holders approve a specific risk parameter called the liquidation ratio. This ratio determines the amount of overcollaterization a CDP requires to avoid liquidation. For example, if the liquidation ratio is 150%, then the value of the collateral must always be one and a half times the value of the Dai generated. If the value of the collateral falls below the liquidation ratio, then the CDP becomes unsafe and is liquidated by the system. The system then takes over the collateral and auctions it off to cover both the debt in the CDP and an applied liquidation penalty.

- The Collateral Auction is triggered when a CDP is liquidated.
	- Any user can liquidate a CDP that is unsafe by sending the bite transaction identifying the CDP.  This will launch a collateral auction. 
	- If the amount of collateral in the CDP being “bitten” is less than the `lot` size for the auction, then there will be one auction for all collateral in the CDP.
	- If the amount of collateral in the CDP being “bitten” is larger than the `lot` size for the auction, then an auction will launch with the full lot size of collateral, and the CDP can be “bitten” again to launch another auction until all collateral in the CDP is up for bidding in Collateral Auctions.

An important aspect of a Collateral Auction is that the auction expiration and bid expiration parameters are dependent on the specific type of collateral, where more liquid collateral types have shorter expiration times and vice-versa.

Once the auction begins, the first bidder will bid an amount of Dai that will cover the outstanding debt associated with the collateral amount (lot). If and when there is a bid that covers the outstanding debt, the auction will turn into a reverse auction, where a bidder bids on accepting smaller parts of the collateral for the fixed amount of Dai that covers the outstanding debt. The auction ends when the bid duration (ttl) has passed OR when the auction duration (tau) has been reached. Again, this process is designed to encourage early bidding. Once the auction is over, the system sends the collateral to the winning bidder’s  address, and the bid Dai is then transferred to the system.

## Debt Auction 
**Summary**: Debt Auctions are used to recapitalize the system by auctioning off MKR for a fixed amount of Dai. In this process, bidders compete with their willingness to accept decreasing amounts of MKR for the fixed Dai they will have to pay.

**High-level Mechanism Process**:
Debt Auctions are triggered when the system has Dai debt that has passed the specified debt limit.

Maker Governance voters determine the debt limit. The Debt auction is triggered when the system has a debt in Dai below that limit.

- In order to determine whether the system has a net debt, the accrued stability fees and debt in the system must be added together. Any user can do this by sending the heal transaction to the system contract named Vow.
- Provided there is a sufficiently sized net debt, the debt auction is triggered when any user sends the flop transaction to the Vow contract

This is a reverse auction, where Keepers bid on how little MKR they are willing to accept for the fixed Dai amount (`lot`) they have to pay at auction settlement. The auction ends when the bid duration (`ttl`) has passed OR when the auction duration (`tau`) has been reached. Once the auction is over, the Dai, paid into the system by bidders in exchange for newly minted MKR, reduces the original debt balance in the system.

## Participate as a Keeper In MCD

We expect that most interactions with Auction contracts will happen via automated Keeper bots. Therefore, the Maker Foundation is focusing on first providing a solid API for Auction Keeper bots, rather than on an attractive user interface. In a future blog post and developer guide, we will explain how a Python Keeper API can be used to build Auction bots.  

In the meantime, anyone interested in participating as a Keeper should start thinking about strategies for bidding on the different types of Auctions. As always, we welcome questions about the Auctions in the [#keeper](https://chat.makerdao.com/channel/keeper) channel in the Maker Chat.
