
# Wallets

This folder contains guides specifically for exchanges seeking to integrate with Maker products.

- [Quick guide for integrating DAI and MKR tokens](/wallets/wallets-guide-01/wallets-guide-01.md)

## Relevant Maker products for wallets

The Maker platform consist of various products that are relevant for wallets. In this guide we will cover the following products:

- [Wallets](#wallets)
  - [Relevant Maker products for wallets](#relevant-maker-products-for-wallets)
    - [Dai Stablecoin](#dai-stablecoin)
    - [Maker token](#maker-token)
    - [Maker Protocol](#maker-protocol)
    - [OTC Trading](#otc-trading)
    - [Price feeds](#price-feeds)
    - [Fiat On-Off Ramps](#fiat-on-off-ramps)

### Dai Stablecoin

One of the main features of the Maker Protocol is the asset-backed cryptocurrency called [Dai](https://makerdao.com/dai) - a cryptocurrency soft-pegged to the USD at a 1:1 ratio. The Maker system ensures that Dai is price stable compared to the USD, why it is also known as a “stablecoin”. Consequently, 1 Dai is equal to 1 USD.

For users Dai is valuable, as it provides the same features as other cryptocurrencies, by being easy and cheap to transfer globally, while keeping a stable price to the USD. This is often useful in countries where fiat currencies are inflationary. In the future, users will be able to earn dividends by holding Dai as an interest rate will be introduced. It also provides an opportunity for crypto-speculators to hedge their positions. Therefore it can be valuable for wallets to integrate Dai, as users are seeking options to obtain and hold the currency.

For more info on how to integrate Dai in your Dapp, read our [Dai Integration Guides](../dai/README.md)

### Maker token

The [Maker token (MKR)](https://makerdao.com/en/whitepaper/#mkr-token-governance) is the other token that comprises the Maker platform. The Maker platform is governed by holders of the MKR tokens, as the tokens are used as votes in governance decisions. The MKR token is also needed to pay back fees in the Dai Credit System, why it is valuable for users of said system to be able to easily access and hold the MKR token in a secure wallet.

For more info about the MKR token, read the [MKR Token Guide](../mkr/mkr-token/mkr-token.md)

### Maker Protocol

The Maker Protocol, is responsible for the issuance of the currency Dai. Dai is created when users lock up cryptographic assets (tokens) as collateral in the system, for which they are able to draw a certain percentage of value in Dai as credit. This is called a Vault position. In the current version, the collateralization ratio for ETH and BAT is 150 %. This means, that your ratio of collateral/credit is 150 %, thus you can only draw 66% worth of Dai to your collateral. This metric ensures that the system is robust in case the collateral drops in value. If the Vaykt becomes under-collateralized, due to a drop in collateral value, the position will be liquidated, the collateral seized and sold off to stabilize the system. In order to control the issuance rate of Dai, there is a stability fee which a user must pay when loaning Dai. Currently, this fee is 4 % APR, which is a lot less than traditional loan schemes. Thus, the Dai Credit System essentially lets users loan money to a very favourable interest rate by locking up collateral tokens.

You can read much more about the Maker Protocol and the underlying functionality [here](http://makerdao.com/whitepaper).

The Maker Protocol functionality can be useful for exchanges that are wishing to create a Vault portal - a way to issue loans with W-ETH or BAT as collateral. It also enables exchanges an automatic way to create leveraged positions, as this system can be used to allow users to loan Dai, convert to ETH, use ETH to create more Dai and so on. However, it can also be valuable for exchanges who have issued their own tokens, to integrate them as collateral for loans, driving the value of the underlying token.

Thus, the credit system can be useful for wallets, who want to:

- Offer asset-backed loans

For more info onhow to integrate with Maker Protocol, read our [Vault Integration Guides](../vault/README.md)

### OTC Trading

The OTC Trading system allows users to buy and sell ERC-20 tokens on the Ethereum blockchain. More specifically, it allows users to create buy and sell orders for DAI, MKR and WETH, allowing for decentralized and automated trade of these tokens. OTC  trading can be useful for wallets who want to:

- Allow their users direct access to the decentralized exchange service

For more info, read on our [Intro to OasisDEX Protocol Guide](../Oasis/intro-to-oasis/intro-to-oasis-maker-otc.md)

### Price feeds

Maker provides an API for trading prices that can [be found here](https://makerdao.com/en/feeds).
The price feeds are valuable for wallets who want to,

- Access market prices for MKR and DAI pairs.

*Todo: Add integrations guides:*

### Fiat On-Off Ramps

Fiat on-off ramps are services that exchanges fiat currencies to Dai, bridging the gap between the fiat and crypto world. Fiat on-off ramps are valuable for remittance, commerce and for users just seeking to cash out Dai holdings in local currencies. It is also valuable for users for do not possess crypto, and want to easily exchange fiat holdings to Dai. Therefore, an on-off ramp partner can be valuable for wallets to:

- Bridge gap between fiat and crypto, and thus drive adoption and user growth
- Allow users to easily cash out cryptocurrency holdings

Maker has partnerships with the following on-off ramps for Dai liquidity and easy Dai to fiat currency conversion, proving a useful resource for remittance services.

- [Wyre](https://www.sendwyre.com/)\
The [Wyre API](https://www.sendwyre.com/docs/) allows for easy exchange between a number of fiat currencies and Dai.\
Checkout [this guide](/partners/wyre/wyre-guide-01/wyre-guide-01.md) to see how to implement their API for cross/border transactions.\
Not supported in [these countries](https://support.sendwyre.com/security/non-operational-states-in-us-and-countries).
- [Ripio](https://www.ripio.com/en/)\
Countries: Argentina, Brazil, (Mexico soon)
You might need a VPN to access their website, if you accessing their service outside South America.
- [Buenbit](https://www.buenbit.com/)\
Countries: Argentina, Peru
- [Orion X](https://orionx.com/)\
Countries: Mexico, Chile
