# Listing DAI or MKR tokens

- [Quick guide - Listing DAI or MKR tokens on exchange](#quick-guide---listing-dai-or-mkr-tokens-on-exchange)
  - [Prerequisites](#prerequisites)
  - [Token contracts](#token-contracts)
    - [Ethereum Mainnet](#ethereum-mainnet)
    - [Kovan Testnet](#kovan-testnet)
    - [Listing symbols](#listing-symbols)
  - [Additional source code and developer docs](#additional-source-code-and-developer-docs)
    - [DSToken (token standard for Maker tokens)](#dstoken-token-standard-for-maker-tokens)
    - [Current Maker Protocol implementation](#current-maker-protocol-implementation)
    - [Token libraries](#token-libraries)
    - [Python API](#python-api)
    - [Maker platform in general](#maker-platform-in-general)
  - [Help](#help)

This document contains the necessary resources for an exchange or wallet to integrate the DAI and MKR ERC-20 tokens.

## Prerequisites

This document assumes familiarity with Ethereum, how to integrate ERC-20 tokens, and basic knowledge of the [Maker platform](https://www.makerdao.com).

## Token contracts

In order to interact directly with the tokens, you can find the Ethereum mainnet smart contract addresses, source code, and ABIs in the links below.
The tokens follow the [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md), and thus should be interoperable with contracts that implement this standard interface.

### Ethereum Mainnet

Live Ethereum mainnet deployments:

- DAI:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[0x6b175474e89094c44da98b954eedeac495271d0f](https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#code)
- MKR:&nbsp;&nbsp;&nbsp;&nbsp;[0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2](https://etherscan.io/address/0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2#code)

### Kovan Testnet

For testing, token contracts on the Kovan testnet can be found here:

- DAI:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa](https://kovan.etherscan.io/address/0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa#code)
- MKR:&nbsp;&nbsp;&nbsp;&nbsp;[0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD](https://kovan.etherscan.io/address/0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd#code)

### Listing symbols

When listing Dai or Maker tokens on exchanges or in wallets, you should use the following currency notations.

- DAI&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Icon source](https://www.notion.so/makerdao/Maker-Brand-ac517c82ff9a43089d0db5bb2ee045a4)
- MKR&nbsp;&nbsp;&nbsp;&nbsp;[Icon source](https://www.notion.so/makerdao/Maker-Brand-ac517c82ff9a43089d0db5bb2ee045a4)

## Additional source code and developer docs

### DSToken (token standard for Maker tokens)

- Docs: <https://dapp.tools/dappsys/ds-token.html>
- Source: <https://github.com/dapphub/ds-token>

### Current Maker Protocol implementation

- Addresses: <https://changelog.makerdao.com>
- Docs: <https://docs.makerdao.com>
- Source: <https://github.com/makerdao/dss>

### Token libraries

**Javascript Library**\
[Dai.js](https://docs.makerdao.com/dai.js) is a javascript library that exposes the functionality of the Maker Protocol smart contracts in a javascript environment, mitigating the need to integrate directly with the smart contract layer. It can, among other things, be used to [implement token transfers](https://github.com/makerdao/dai.js#usage).

- Docs: <https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki>
- Source: <https://github.com/makerdao/dai.js>

### Python API

Similarly to the library above, the [Python API](https://github.com/makerdao/pymaker) provides endpoints to interact with the smart contracts in a Python environment, such as [endpoints for token transfers](https://github.com/makerdao/pymaker#token-transfer).

- Docs/source: <https://github.com/makerdao/pymaker>

### Maker platform in general

- [Maker Protocol Whitepaper](https://makerdao.com/whitepaper/)

## Help

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel
