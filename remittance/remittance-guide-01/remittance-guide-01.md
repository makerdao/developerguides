
# Quick guide - Integrating DAI for remittance services
This document contains the necessary resources to integrate the DAI token for remittance services.

## Prerequisites
This document assumes familiarity with Ethereum, how to integrate ERC-20 tokens, and basic knowledge of the [Maker platform](https://www.makerdao.com).

## Dai token contract
In order to interact directly with the DAI token, you can find the deployed smart contract addresses, source code, and ABIs in the links below.
The DAI token follows the [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md), and thus should be interoperable with contracts that implement this standard interface.

### Live Dai token smart contract deployments
* Ethereum Mainnet DAI: [0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359](https://etherscan.io/address/0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359#code)
* Kovan Testnet DAI: [0xC4375B7De8af5a38a93548eb8453a498222C4fF2](https://kovan.etherscan.io/address/0xC4375B7De8af5a38a93548eb8453a498222C4fF2#code)

### Listing symbols
When listing DAI in your implementation, you should use the following currency notations.
* DAI&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Icon source](https://github.com/makerdao/Overview-of-MakerDAO-design/tree/master/DAI)

A style guide and additional logos can [be found here](https://github.com/makerdao/Overview-of-MakerDAO-design#style-guide).

## Token libraries
### Javascript Library
[Dai.js](https://makerdao.com/documentation/) is a javascript library that exposes the functionality of the smart contracts in a javascript environment, mitigating the need to integrate directly with the smart contract layer. It can, among other things, be used to [implement token transfers](https://github.com/makerdao/dai.js#usage), and [OTC exchange services](https://makerdao.com/documentation/#exchange-service) to obtain DAI liquidity, in return for other ERC20 tokens.

**Python API**\
Similarly to the library above, the [Python API](https://github.com/makerdao/pymaker) provides endpoints to interact with the smart contracts in a Python environment, such as [endpoints for token transfers](https://github.com/makerdao/pymaker#token-transfer).

## Fiat on-off ramps
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


## Additional source code and developer docs
**DSToken (token standard for Maker tokens)**
* Docs: https://dapp.tools/dappsys/ds-token.html
* Source: https://github.com/dapphub/ds-token

**Current Dai credit system implementation**
* Docs: https://developer.makerdao.com/dai/1/api/
* Docs: https://github.com/makerdao/sai/blob/master/DEVELOPING.md
* Source: https://github.com/makerdao/sai

**Dai.js Javascript Library**
* Docs: https://makerdao.com/documentation/
* Source: https://github.com/makerdao/dai.js

**Python API**
* Docs/source: https://github.com/makerdao/pymaker

**Maker platform in general**
* [Dai Credit System Whitepaper](https://makerdao.com/whitepaper/)

## Need help?
Contact integrate@makerdao.com or #dev channel on [chat.makerdao.com](https://chat.makerdao.com/)
