# Exchanges
This folder contains guides specifically for exchanges seeking to integrate with Maker products.
This document will outline which Maker products are relevant for exchanges, and how they can provide value. Furthermore this document will point to important resources explaining how to integrate with these systems and how they work.

If you are already familiar with Ethereum, the ERC-20 token standard and Solidity smart contracts, you can checkout this guide for listing DAI and MKR tokens:

* [Quick guide for listing DAI and MKR tokens](/exchanges/exchanges-guide-01/exchanges-guide-01.md)

## Relevant Maker products for exchanges
The Maker platform consist of various products that are relevant for exchanges. In this guide we will cover the following products:
-   Dai stablecoin   
-   Maker token   
-   Dai credit system  
-   OasisDex  
-   Price feeds (Oracles)   
-   Fiat On/Off Ramps

### Dai Stablecoin
One of the main features of the Maker platform is the asset-backed cryptocurrency called [Dai](https://makerdao.com/dai) - a cryptocurrency soft-pegged to the USD at a 1:1 ratio. The Maker system ensures that Dai is price stable compared to the USD, why it is also known as a “stablecoin”. Consequently, 1 Dai is equal to 1 USD.

A stablecoin is useful for exchanges as it provides a way for users to hedge their positions, or exchange more volatile cryptocurrencies to a currency price stable towards the USD, without having to exchange to fiat currencies.

For users Dai is valuable, as it provides the same features as other cryptocurrencies, by being easy and cheap to transfer globally, while keeping a stable price to the USD. This is often useful in countries where fiat currencies are inflationary. In the future, users will be able to earn dividends by holding Dai as an interest rate will be introduced. Therefore it can be valuable for exchanges to list Dai, as users are seeking options to obtain the currency.

### Maker token
The [Maker token (MKR)](https://makerdao.com/en/whitepaper/#mkr-token-governance) is the other token that comprises the Maker platform. The Maker platform is governed by holders of the MKR tokens, as the tokens are used as [votes in governance decisions](https://vote.makerdao.com/). The MKR token [fluctuates in value](https://coinmarketcap.com/currencies/maker/), why speculators might seek ways to obtain the token through an exchange. The MKR token is also needed to pay back fees in the Dai Credit System, why it is valuable for users of said system to be able to easily access the MKR token.

### Dai Credit System
The Dai Credit System, is responsible for the issuance of the currency Dai. Dai is created when users lock up cryptographic assets (tokens) as collateral in the system, for which they are able to draw a certain percentage of value in Dai as credit. This is called a collateralized debt position (CDP). In the current implementation of the system, the only accepted collateral is Wrapped Ether (W-ETH), however with the launch of Multi-Collateral Dai (MCD), more collateral types will be made available. Furthermore, in the current version, the collateralization ratio is 150 %. This means, that your ratio of collateral/credit is 150 %, thus you can only draw 66% worth of Dai to your collateral. This metric ensures that the system is robust in case the collateral drops in value. If the CDP becomes under-collateralized, due to a drop in collateral value, the position will be liquidated, the collateral seized and sold off to stabilize the system. In order to control the issuance rate of Dai, there is a stability fee which a user must pay when loaning Dai. Currently, this fee is 0.5 % APR, which is a lot less than traditional loan schemes. Thus, the Dai Credit System essentially lets users loan money to a very favourable interest rate by locking up collateral tokens.

You can read much more about the Dai Credit System and the underlying functionality [here](http://makerdao.com/whitepaper).

The Dai Credit System functionality can be useful for exchanges for a wishing to create a CDP portal - a way to issue loans with W-ETH as collateral. It also enables exchanges an automatic way to create leveraged positions, as this system can be used to allow users to loan Dai, convert to ETH, use ETH to create more Dai and so on. However, it can also be valuable for exchanges who have issued their own tokens, to integrate them as collateral for loans, driving the value of the underlying token.

Thus, the credit system can be useful for exchanges, who want to,
-   Offer asset-backed loans   
-   Create leveraged positions 
-   Provide a collateral type

### OasisDex
OasisDex is a decentralized exchange solution by Maker. The system allows users to buy and sell ERC-20 tokens on the Ethereum blockchain. More specifically, it allows users to create buy and sell orders for DAI, MKR and WETH, allowing for decentralized and automated trade of these tokens. OasisDex can be useful for exchanges who want to:
-   Allow their users direct access to the decentralized exchange service   
-   Obtain liquidity in certain in MKR or DAI (without creating CDP)  

### Price feeds
OasisDex provides an API for trading prices that can [be found here](https://developer.makerdao.com/oasis/api/1/).
The price feeds are valuable for exchanges who want to
-   Access market prices for MKR and DAI pairs.

### Fiat On-Off Ramps
Fiat on-off ramps are services that exchanges fiat currencies to Dai, bridging the gap between the fiat and crypto world. Fiat on-off ramps are valuable for remittance, commerce and for users just seeking to cash out Dai holdings in local currencies. It is also valuable for users for do not possess crypto, and want to easily exchange fiat holdings to Dai. Therefore, an on-off ramp partner can be valuable for exchanges to
-   Bridge gap between fiat and crypto, and thus drive adoption and user growth
-   Cash out cryptocurrencies
Read more about our fiat on-off ramp partners here.