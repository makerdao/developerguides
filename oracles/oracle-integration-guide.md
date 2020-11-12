# Oracle Integration Guide

Level: **Intermediate**  
Estimated Time: **30 minutes**

- [Oracle Integration Guide](#oracle-integration-guide)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Oracle Module](#oracle-module)
  - [Applying to the Oracle Whitelist](#applying-to-the-oracle-whitelist)
  - [Summary](#summary)
  - [Additional Resources](#additional-resources)

## Overview

The Maker Protocol allows its users to generate Dai from an array of different asset types accepted by the Maker Governance. The Maker Protocol utilizes an Oracle Module in order to monitor the prevailing market price of each asset to ensure positions are sufficiently collateralized. Adding new Oracles, whether for onboarding or monitoring collateral or for external use, is initiated by the community and implemented by the [Oracle Domain Team](https://forum.makerdao.com/t/mandate-oracle-teams/443)(s). In this guide, you will learn about the Oracles Module, learn how to integrate with the Oracles through a smart contract, read the price feed, and how to get whitelisted by Maker Governance.

## Learning Objectives

- Understand the Oracles Module
- Integrate with the Oracle Module through a smart contract
- Apply to get whitelist access to an Oracle

## Pre-requisites

- [Maker Protocol 101](https://docs.makerdao.com/maker-protocol-101)
- [The MIP Framework](https://forum.makerdao.com/t/mip0-the-maker-improvement-proposal-framework/1902)

## Oracle Module

The Maker Oracle Module contains all the logic to receive and process price data for each collateral asset in the protocol.

The OSM ("[Oracle Security Module](https://docs.makerdao.com/smart-contract-modules/oracle-module/oracle-security-module-osm-detailed-documentation)") ensures that new price values broadcast by the Oracles are not taken up by the system until a specified delay has passed.  
The read() and peek() methods will give the current value of the price feed.  
The peep() method will give you the future value of the price feed.  
In order for other smart contracts or Ethereum accounts to call these methods, they must be whitelisted - read more in the “Apply to get whitelisted” section.  
An OSM contract can only read from a single source, so in practice one OSM contract must be deployed per collateral type.

The latest contract addresses for each collateral oracle contract can be found in the [changelog](https://changelog.makerdao.com/releases/mainnet/active/contracts.json). Each collateral asset will have a contract address named as PIP_collateralName. For example, for the ETH collateral type, you’ll find the oracle contract as this: [PIP_ETH](https://etherscan.io/address/0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763#code)

To read the price of the PIP_ETH contract on-chain, you have to create a smart contract that will call the reading functions in the PIP_ETH contract.

The available reading functions in the PIP_ETH or any other OSM contract are:

- peek(): returns the current feed value and a boolean indicating whether it is valid
- peep(): returns the next feed value (i.e. the one that will become the current value upon the next poke() call), and a boolean indicating whether it is valid
- read(): returns the current feed value; reverts if it was not set by some valid mechanism

Below is a simple example contract that can read the future price feed (peep) from the PIP_ETH contract:

NB: This contract won’t be able to read the price feed if it is not whitelisted by Maker Governance.

```solidity
pragma solidity ^0.6.6;

interface OracleSecurityModule {
    function peek() external view returns (bytes32, bool);

    function peep() external view returns (bytes32, bool);

    function bud(address) external view returns (uint256);

    function read() external view returns (bytes32);
}

contract ETHFeedReader {

    address public owner;

    // KOVAN PIP_ETH address
    OracleSecurityModule public constant osm = OracleSecurityModule(0x75dD74e8afE8110C8320eD397CcCff3B8134d981);

    constructor() public {
        owner = msg.sender;
    }

    //returns the future feed value
    function getPrice() view external returns (uint256) {
        (bytes32 val, bool has) = osm.peep();
        uint256 result = uint256(val);
        return result;
    }
}


```
  
Reading collateral prices from the Oracles on-chain is only possible if the reading contract is whitelisted in the OSM contracts for each collateral asset. The whitelisting mechanism serves to provide transparency to consumers of the Oracle data in an effort to prevent the build-up of unknown systemic risk in the DeFi ecosystem.

There are multiple methods to read Oracle prices off-chain. It is possible to read Oracle prices in an off-chain environment without being whitelisted. Below are two examples of how to read Oracle prices with Dai.js and [Seth](http://dapp.tools/seth/):

- Using Dai.js:
- [Documentation](https://docs.makerdao.com/dai.js/currency-units)
- [OSM functions](https://github.com/makerdao/dai.js/blob/dcd3945de2812e6eadbdd427ab8bd700eb63c57b/packages/dai-plugin-mcd/src/schemas/osm.js)
- Using seth:
  
Below command assumes you have seth setup.

```bash
OSM=address of oracle contract  
storage=$(seth storage $OSM 0x4)

price=$(seth --from-wei "$(seth --to-dec "${storage:34:32}")")

echo $price

1934.814612130400000000
```
  
## Applying to the Oracle Whitelist

To read Oracle prices on-chain from the Maker Oracles a user must apply for the whitelist by filling out a subproposal and publishing it to the Oracles section of the [Maker Forum](https://forum.makerdao.com/c/oracles/13). Attempting to read from the Oracles without whitelist access will return an invalid price. An example of this situation can be found [here](https://forum.makerdao.com/t/how-to-consume-data-from-the-price-feeds/2648).

The subproposal process is part of the [MIP framework](https://forum.makerdao.com/t/mip0-the-maker-improvement-proposal-framework/1902) of the Maker Protocol. In this framework, there is a MIP directed towards anything related to Oracles. This MIP (Maker Improvement Proposal) is the [MIP10 Oracle Management](https://github.com/makerdao/mips/blob/master/MIP10/mip10.md#mip10c9-process-to-whitelist-oracle-access). To apply for whitelist access in the Maker Protocol, you will have to use a specific subproposal process. The name of that process is [MIP10c9: Process to Whitelist Oracle Access](https://github.com/makerdao/mips/blob/master/MIP10/mip10.md#mip10c9-process-to-whitelist-oracle-access).

In the subproposal, a user will provide context about their project and motivation for needing to read a specific Oracle from the Maker Protocol. The subproposal also includes additional requirements such as the proper scoping of Oracle data such that an external contract can’t parasitically leach Oracle prices via the proposed contract.

In the [MIP10c9: Process to Whitelist Oracle Access](https://github.com/makerdao/mips/blob/master/MIP10/mip10.md#mip10c9-process-to-whitelist-oracle-access) link, you will find more information about the proposal and how to apply. Briefly, an applicant will have to:

- Fill out the [subproposal](https://github.com/makerdao/mips/blob/master/MIP10/MIP10c9-Subproposal-Template.md)
- Do a pull request in the [github repository](https://github.com/makerdao/mips/tree/master/MIP10/MIP10c9-Subproposals) with the filled subproposal.
- Develop, deploy and verify their contract on Etherscan. This contract will interface with the Oracle Module and read the price feed. This contract is the OSM interface in your own application that needs the Oracle price.
- Publish your subproposal on [forum.makerdao.com](https://forum.makerdao.com/c/oracles/13) in the Oracles category.
- Wait until Maker Governance approves your proposal in the governance cycle. All votes can be viewed at [vote.makerdao.com](https://vote.makerdao.com/)
- If the contract address is approved by governance, it is added to the whitelist. Once added to the whitelist, a contract is eligible to read on-chain price data from the selected OSM contract.

To find more examples of previous whitelisted contracts in the OSM, look at this [list of Oracles Whitelists](https://github.com/makerdao/mips/blob/master/MIP10/MIP10c11-List-of-Oracle-Whitelists.md).

Overall, as an applicant for whitelisting or any other process, you will have to engage with the MakerDAO community via the [Maker Forum.](https://forum.makerdao.com/) There, you will find discussions regarding other MIP processes and Maker Protocol current events. It is recommended that you participate in these discussions and actively join the MakerDAO community. This way, you bring awareness about your project to the community and receive feedback.

## Summary

This guide introduced the Oracle Module of the Maker Protocol and provided instructions for integrating the Maker Oracles as well as how to apply to get whitelist access via Maker Governance.

## Additional Resources

- [Deconstructing the Oracle Stack Video at ETHDenver 2020](https://www.youtube.com/watch?v=lpPfqj88hho)
