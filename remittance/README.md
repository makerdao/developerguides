# Remittance Services
This folder contains guides specifically for remittance services seeking to integrate with Maker products.

* [Quick guide for integrating DAI for remittance](/remittance/remittance-guide-01/remittance-guide-01.md)

## Relevant Maker products for remittance services

The Maker platform consist of various products that are relevant for remittance services. In this guide we will cover the following products:
-   [Dai stablecoin](#dai-stablecoin)
-   [Fiat On-Off Ramps](#fiat-on-off-ramps)   
   
### Dai Stablecoin

One of the main features of the Maker platform is the asset-backed cryptocurrency called [Dai](https://makerdao.com/dai) - a cryptocurrency soft-pegged to the USD at a 1:1 ratio. The Maker system ensures that Dai is price stable compared to the USD, why it is also known as a “stablecoin”. Consequently, 1 Dai is equal to 1 USD.

For users Dai is valuable, as it provides the same features as other cryptocurrencies, by being easy and cheap to transfer globally, while keeping a stable price to the USD. This is often useful in countries where fiat currencies are inflationary. In the future, users will be able to earn dividends by holding Dai as an interest rate will be introduced. It also provides an opportunity for crypto-speculators to hedge their positions. Therefore it can be valuable for wallets to integrate Dai, as users are seeking options to obtain and hold the currency.

*Todo: Add integrations guides*

### Fiat On-Off Ramps
Fiat on-off ramps are services that exchanges fiat currencies to Dai, bridging the gap between the fiat and crypto world. Fiat on-off ramps are valuable for remittance, commerce and for users just seeking to cash out Dai holdings in local currencies. It is also valuable for users for do not possess crypto, and want to easily exchange fiat holdings to Dai. Therefore, an on-off ramp partner can be valuable for wallets to:
-   Bridge gap between fiat and crypto, and thus drive adoption and user growth
    
-   Allow users to easily cash out cryptocurrency holdings

Maker has partnerships with the following on-off ramps for Dai liquidity and easy Dai to fiat currency conversion, proving a useful resource for remittance services.
* [Wyre](https://www.sendwyre.com/)\
The [Wyre API](https://www.sendwyre.com/docs/) allows for easy exchange between a number of fiat currencies and Dai.\
Checkout [this guide](/partners/wyre/wyre-guide-01/wyre-guide-01.md) to see how to implement their API for cross/border transactions.\
Not supported in [these countries](https://support.sendwyre.com/security/non-operational-states-in-us-and-countries).
* [Ripio](https://www.ripio.com/en/)\
Countries: Argentina, Brazil, (Mexico soon)
You might need a VPN to access their website, if you accessing their service outside South America.
* [Buenbit](https://www.buenbit.com/)\
Countries: Argentina, Peru
* [Orion X](https://orionx.com/)\
Countries: Mexico, Chile
