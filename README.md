# Developer Guides and Tutorials

Developers can build a variety of experiences using one or more components of the Maker Protocol. This repo contains guides and tutorials to help you understand various approaches to integrate with the Maker Protocol and our partners by interfacing with smart contracts, SDKs, APIs, and products.

All guides are organized in sections and by proficiency levels within each section.

## Dai

- [Dai Token](https://github.com/makerdao/developerguides/tree/master/dai/dai-token/dai-token.md)
- [Dai in Smart Contracts](https://github.com/makerdao/developerguides/tree/master/dai/dai-in-smart-contracts/README.md)
- [Tracking Dai Supply](https://github.com/makerdao/developerguides/tree/master/dai/dai-supply/dai-supply.md)

## Dai Savings Rate (DSR)

- [Dai Savings Rate integration guide](https://github.com/makerdao/developerguides/tree/master/dai/dsr-integration-guide/dsr-integration-guide-01.md)
- [DsrManager documentation](/dai/dsr-manager-docs/README.md)

## Vaults

- [Maker Vault Integration Guide](https://github.com/makerdao/developerguides/tree/master/vault/vault-integration-guide/vault-integration-guide.md)
- [Monitoring Collateral Types and Vaults](https://github.com/makerdao/developerguides/tree/master/vault/monitoring-collateral-types-and-vaults/monitoring-collateral-types-and-vaults.md)

## Emergency Shutdown

- [Emergency Shutdown guide](https://github.com/makerdao/developerguides/blob/master/mcd/emergency-shutdown/emergency-shutdown-guide.md)

## Maker Protocol / Multi-Collateral Dai

- [Introduction and Overview of Multi-Collateral Dai: MCD101](https://github.com/makerdao/developerguides/tree/master/mcd/mcd-101/mcd-101.md)
- [Using MCD-CLI to create and close a Vault on Kovan](https://github.com/makerdao/developerguides/tree/master/mcd/mcd-cli/mcd-cli-guide-01/mcd-cli-guide-01.md)
- [Using Seth to create and close a Vault on Kovan](https://github.com/makerdao/developerguides/tree/master/mcd/mcd-seth/mcd-seth-01.md)
- [Upgrading to MCD - overview for different partners](https://github.com/makerdao/developerguides/tree/master/mcd/upgrading-to-multi-collateral-dai/upgrading-to-multi-collateral-dai.md)
- [Add a new collateral type to Maker Protocol - Kovan](https://github.com/makerdao/developerguides/tree/master/mcd/add-collateral-type-testnet/add-collateral-type-testnet.md)
- [Intro to the Rate mechanism](https://github.com/makerdao/developerguides/tree/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)

## Keepers (Collateral Auctions, Debt Auctions, Arbitrage)

- [Keeper Guides Repo](https://github.com/makerdao/developerguides/tree/master/keepers)
- [Auctions 101](https://github.com/makerdao/developerguides/tree/master/keepers/auctions/auctions-101.md)
- [Auction Keeper Setup Guide](https://github.com/makerdao/developerguides/blob/master/keepers/auction-keeper-bot-setup-guide.md)
- [Simple Arbitrage Keeper](https://github.com/makerdao/developerguides/tree/master/keepers/simple-arbitrage-keeper/simple-arbitrage-keeper.md)

## Developer Tools

- [Test Chain Guide](https://github.com/makerdao/developerguides/tree/master/devtools/test-chain-guide/test-chain-guide.md)
- [Introduction to Seth](https://github.com/makerdao/developerguides/tree/master/devtools/seth/seth-guide-01/seth-guide-01.md)
- [Working with DSProxy](https://github.com/makerdao/developerguides/tree/master/devtools/working-with-dsproxy/working-with-dsproxy.md)
- [How to build a Dai.js wallet plugin](https://github.com/makerdao/developerguides/blob/master/devtools/Dai.js/How-to-build-dai-js-wallet-plugin.md)

## Oasis Exchange

- [Intro to OasisDEX Protocol](https://github.com/makerdao/developerguides/tree/master/Oasis/intro-to-oasis/intro-to-oasis-maker-otc.md)
- [How to use Oasis Direct Proxy on OasisDEX Protocol](https://github.com/makerdao/developerguides/tree/master/Oasis/oasis-direct-proxy.md)

## Governance

- [Vote Proxy Setup: Air-gapped Machine](https://github.com/makerdao/developerguides/tree/master/governance/vote-proxy-setup-airgapped-machine/vote-proxy-setup-airgapped-machine.md)

## Partners

- [Setting up real money transfers using Wyre API](https://github.com/makerdao/developerguides/tree/master/partners/wyre-guide-01/wyre-guide-01.md)

### Gnosis Multisig Wallet

- [Migrating Sai to Dai using Gnosis Multisig Wallet UI](https://github.com/makerdao/developerguides/tree/master/gnosis-multisig/migrating-gnosis-multisig-guide/migrating-gnosis-multisig-guide-01.md)
- [Activating Dai Savings Rate on Dai in Gnosis Multisig Wallet](https://github.com/makerdao/developerguides/tree/master/gnosis-multisig/dsr-gnosis-multisig-guide/dsr-gnosis-multisig-guide-01.md)
- [Vote Proxy Setup with Gnosis Multisig Wallet](https://github.com/makerdao/developerguides/blob/master/gnosis-multisig/vote-proxy-setup-gnosis-multisig/vote-proxy-setup-gnosis-multisig.md)

## Partner compilations

In order to ensure that integration partners can get up and running quickly, relevant documentation for specific partner types have been compiled in a series of guides.

- [Upgrading to Multi-Collateral Dai](https://github.com/makerdao/developerguides/tree/master/mcd/upgrading-to-multi-collateral-dai/cli-mcd-migration.md)
- [Exchanges](https://github.com/makerdao/developerguides/tree/master/exchanges/README.md)
- [Wallets](https://github.com/makerdao/developerguides/tree/master/wallets/README.md)
- [Remittance services](https://github.com/makerdao/developerguides/tree/master/remittance/README.md)
- [Market Makers](https://github.com/makerdao/developerguides/tree/master/market-makers/README.md)

## Contribution guidelines

We welcome submissions of guides and tutorials that cover new types of integrations! Following these guidelines will help us maintain consistency,

- Include all the sections present in this [sample guide](https://github.com/makerdao/developerguides/tree/master/sample/sample-guide-01/sample-guide-01.md)  
- Create a folder with one markdown file using the same name
- Append a number if a guide needs to be split into multiple parts

## License

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
