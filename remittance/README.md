# Remittance Services
This folder contains guides specifically for remittance services seeking to integrate with Maker products.

## Prerequisites
This document assumes familiarity with Ethereum, how to integrate ERC-20 tokens, and basic knowledge of the [Maker platform](https://www.makerdao.com).

## Relevant Maker products for remittance services

The Maker platform consist of various products that are relevant for remittance services. In this guide we will cover the following products:
-   [Dai stablecoin](#dai-stablecoin)
-   [Fiat On-Off Ramps](#fiat-on-off-ramps)   
   
### Dai Stablecoin

One of the main features of the Maker Protocol is the asset-backed cryptocurrency called [Dai](https://makerdao.com/dai) - a cryptocurrency soft-pegged to the USD at a 1:1 ratio. The Maker system ensures that Dai is price stable compared to the USD, therefore it is also known as a “stablecoin”. Consequently, 1 Dai is equal to 1 USD.

For users Dai is valuable, as it provides the same features as other cryptocurrencies, by being easy and cheap to transfer globally, while keeping a stable price to the USD. This is often useful in countries where fiat currencies are inflationary. In the future, users will be able to earn dividends by holding Dai as an interest rate will be introduced. It also provides an opportunity for crypto-speculators to hedge their positions. Therefore it can be valuable for remittance services to integrate Dai, as users are seeking ways to easily transfer globally, and hold a stable currency.

#### Dai token contract
In order to interact directly with the DAI token, you can find the deployed smart contract addresses, source code, and ABIs in the links below.
The DAI token follows the [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md), and thus should be interoperable with contracts that implement this standard interface.

##### Live Dai token smart contract deployments
* Ethereum Mainnet DAI: [0x6b175474e89094c44da98b954eedeac495271d0f](https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#code)
* Kovan Testnet DAI: [0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa](https://kovan.etherscan.io/address/0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa#code)

##### Listing symbols
When listing DAI in your implementation, you should use the following currency notations.
* DAI&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Icon source](https://www.notion.so/makerdao/Maker-Brand-ac517c82ff9a43089d0db5bb2ee045a4)

A style guide and additional logos can [be found here](https://www.notion.so/makerdao/Maker-Brand-ac517c82ff9a43089d0db5bb2ee045a4).

### Token libraries
#### Javascript Library
[Dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki) is a javascript library that exposes the functionality of the smart contracts in a javascript environment, mitigating the need to integrate directly with the smart contract layer. It can, among other things, be used to [implement token transfers](https://github.com/makerdao/dai.js#usage).

#### Python API
Similarly to the library above, the [Python API](https://github.com/makerdao/pymaker) provides endpoints to interact with the smart contracts in a Python environment, such as [endpoints for token transfers](https://github.com/makerdao/pymaker#token-transfer).

## Fiat On-Off Ramps
Fiat on-off ramps are services that exchanges fiat currencies to Dai, bridging the gap between the fiat and crypto world. Fiat on-off ramps are valuable for remittance, commerce and for users just seeking to cash out Dai holdings in local currencies. It is also valuable for users, who do not possess crypto, and want to easily exchange fiat holdings to Dai. Therefore, an on-off ramp partner can be valuable for wallets to:
-   Bridge the gap between fiat and crypto, and thus drive adoption and user growth
    
-   Allow users to easily cash out cryptocurrency holdings

Maker has partnerships with the following on-off ramps for Dai liquidity and easy Dai to fiat currency conversion, proving a useful resource for remittance services.
* [Wyre](https://www.sendwyre.com/)\
The [Wyre API](https://www.sendwyre.com/docs/) allows for easy exchange between a number of fiat currencies and Dai.\
Checkout [this guide](/partners/wyre-guide-01/wyre-guide-01.md) to see how to implement their API for cross/border transactions.\
Not supported in [these countries](https://support.sendwyre.com/security/non-operational-states-in-us-and-countries).
* [Ripio](https://www.ripio.com/en/)\
Countries: Argentina, Brazil, (Mexico soon)
You might need a VPN to access their website, if you accessing their service outside South America.
* [Buenbit](https://www.buenbit.com/)\
Countries: Argentina, Peru
* [Orion X](https://orionx.com/)\
Countries: Mexico, Chile

## Additional source code and developer docs
**DSToken (token standard for Maker tokens)**
- Docs: https://dapp.tools/dappsys/ds-token.html
- Source: https://github.com/dapphub/ds-token

**Current Maker Protocol implementation**
- Addresses: https://changelog.makerdao.com/
- Docs: https://docs.makerdao.com/
- Source: https://github.com/makerdao/dss

**Dai.js Javascript Library**
- Docs: https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki
- Source: https://github.com/makerdao/dai.js

**Python API**
- Docs/source: https://github.com/makerdao/pymaker

**Maker platform in general**
-  [Whitepaper](https://makerdao.com/whitepaper/)

## Need help?
Contact integrate@makerdao.com or #dev channel on chat.makerdao.com
