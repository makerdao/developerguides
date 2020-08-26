# Quick guide - Integrating DAI or MKR tokens in wallets

This document contains the necessary resources to integrate the DAI and MKR ERC-20 tokens into a wallet.

- [Quick guide - Integrating DAI or MKR tokens in wallets](#quick-guide---integrating-dai-or-mkr-tokens-in-wallets)
  - [Prerequisites](#prerequisites)
  - [Token contracts](#token-contracts)
  - [Token libraries](#token-libraries)
  - [Additional source code and developer docs](#additional-source-code-and-developer-docs)
  - [Need help](#need-help)

## Prerequisites

This document assumes familiarity with Ethereum, how to integrate ERC-20 tokens, and basic knowledge of the [Maker platform](https://www.makerdao.com).

## Token contracts

In order to interact directly with the tokens, you can find the Ethereum mainnet smart contract addresses, source code, and ABIs in the links below.
The tokens follow the [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md), and thus should be interoperable with contracts that implement this standard interface.

**Ethereum Mainnet**\

Live Ethereum mainnet deployments:

- DAI:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359](https://etherscan.io/address/0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359#code)
- MKR:&nbsp;&nbsp;&nbsp;&nbsp;[0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2](https://etherscan.io/address/0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2#code)

**Kovan Testnet**\

For testing, token contracts on the Kovan testnet can be found here:

- DAI:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[0xC4375B7De8af5a38a93548eb8453a498222C4fF2](https://kovan.etherscan.io/address/0xC4375B7De8af5a38a93548eb8453a498222C4fF2#code)
- MKR:&nbsp;&nbsp;&nbsp;&nbsp;[0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD](https://kovan.etherscan.io/address/0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd#code)

**Listing symbols**\

When listing Dai or Maker tokens on exchanges or in wallets, you should use the following currency notations.

- DAI&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Icon source](https://github.com/makerdao/Overview-of-MakerDAO-design/tree/master/DAI)
- MKR&nbsp;&nbsp;&nbsp;&nbsp;[Icon source](https://github.com/makerdao/Overview-of-MakerDAO-design/tree/master/MKR)

A style guide and additional logos can [be found here](https://github.com/makerdao/Overview-of-MakerDAO-design#style-guide).

## Token libraries

**Javascript Library**\
[Dai.js](https://makerdao.com/documentation/) is a javascript library that exposes the functionality of the smart contracts in a javascript environment, mitigating the need to integrate directly with the smart contract layer. It can, among other things, be used to [implement token transfers](https://github.com/makerdao/dai.js#usage).

**Python API**\
Similarly to the library above, the [Python API](https://github.com/makerdao/pymaker) provides endpoints to interact with the smart contracts in a Python environment, such as [endpoints for token transfers](https://github.com/makerdao/pymaker#token-transfer).

## Additional source code and developer docs

**DSToken (token standard for Maker tokens):**

- Docs: <https://dapp.tools/dappsys/ds-token.html>
- Source: <https://github.com/dapphub/ds-token>

**Current Dai credit system implementation:**

- Docs: <https://developer.makerdao.com/dai/1/api/>
- Docs: <https://github.com/makerdao/sai/blob/master/DEVELOPING.md>
- Source: <https://github.com/makerdao/sai>

**Dai.js Javascript Library:**

- Docs: <https://makerdao.com/documentation/>
- Source: <https://github.com/makerdao/dai.js>

**Python API:**

- Docs/source: <https://github.com/makerdao/pymaker>

**Maker platform in general:**

- [Dai Credit System Whitepaper](https://makerdao.com/whitepaper/)

## Need help

Contact integrate@makerdao.com or #dev channel on [chat.makerdao.com](https://chat.makerdao.com/)
