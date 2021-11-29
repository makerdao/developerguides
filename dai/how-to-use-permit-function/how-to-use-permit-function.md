---
title: How to use permit function and relayers to pay gas for Dai transactions in Dai
description: Learn about Dai permit function
parent: dai
tags:
  - dai
  - permit funciton
  - gassless dai  
slug: how-to-use-permit-function-and-relayers-to-pay-gas-for-dai transactions-in-dai
contentType: guides
root: false
---

# How to use permit function and relayers to pay gas for Dai transactions in Dai

**Level:** Intermediate  
**Estimated Time**: 30 min

- [How to use permit function and relayers to pay gas for Dai transactions in Dai](#how-to-use-permit-function-and-relayers-to-pay-gas-for-dai-transactions-in-dai)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Overview of meta transactions](#overview-of-meta-transactions)
  - [Permit](#permit)
    - [The Typed Signed Data standard](#the-typed-signed-data-standard)
    - [Permit in the Dai contract](#permit-in-the-dai-contract)
      - [Note on security](#note-on-security)
      - [Example with web3js](#example-with-web3js)
    - [Create signed message with web3js](#create-signed-message-with-web3js)
    - [Relay transaction with another wallet account from your Metamask account](#relay-transaction-with-another-wallet-account-from-your-metamask-account)
    - [Transfers](#transfers)
    - [Relaying to Ethereum Network](#relaying-to-ethereum-network)
  - [Notes on Gas Station Network](#notes-on-gas-station-network)
  - [Summary](#summary)
  - [Additional Resources](#additional-resources)
  - [Help](#help)

## Overview

With the deployment of MCD, the Dai token has received an improvement in its token contract. This improvement is the addition of a new function called [permit](https://github.com/makerdao/dss/blob/master/src/dai.sol#L118). This function, which in its own is made possible by the [EIP712](https://eips.ethereum.org/EIPS/eip-712) standard, allows service provider to create integrations that allows Dai holders to pay their transaction fees in Dai, eliminating the need to have Ether to pay for gas on transactions involving Dai.  
Through this feature, we are one step closer to improving user experience and adoption in the crypto ecosystem.

In this guide, you will learn more about how this feature works and how you could implement it in your own dapp.

## Learning Objectives

Understand the permit function and how to use it in your dApp for gasless Dai transactions, where you pay for transaction fees in Dai.

- Permit function
- Relayers
- Creating gasless Dai transactions

## Pre-requisites

Knowledge of:

- [Dai token contract](https://docs.makerdao.com/smart-contract-modules/dai-module/dai-detailed-documentation)
- [Solidity](https://solidity.readthedocs.io/)
- [Web3js](https://web3js.readthedocs.io/)

## Overview of meta transactions

![Meta Transactions Figure](https://lh3.googleusercontent.com/8vjG4YeUPJ3cl802LbrJKaoRLlYBQ04oSPkxyCA7X_ASSoJ0ZIgGdbCKdyHlj_L-8B3k0kHNyo5kV-dl44u8oOE2hP96oQm691iyPGi9O2GI-APABHIfRrfrPNcRWV7rEU9JcxY)

When interacting with smart contracts on the Ethereum blockchain, users always need to make a transaction by paying some gas with their wallet address. The user signs the transaction with his wallet and then relays it to the node that his wallet is connected to.

With meta transactions, the user could make transactions on the Ethereum blockchain without directly paying for the transaction fee in Ether, but in the token that he has in his wallet.

The meta transactions work by having the user sign the transaction and then pass that signed transaction or message to a third party service that will relay his transaction onto the blockchain.

This third party service is called a relayer and since there is no such thing as a free lunch, this relayer has to be incentivized to relay the transaction. The incentive comes as a fee that the user pays in the native token that he wants to transfer in the first place. It is up to the relayer how he designs his fee structure. It can have a pool of Ether ready to be used for broadcasting the incoming signed transactions or do the process on the fly by exchanging the token into Ether and using that to broadcast the transaction. And claiming a small fee on top of the transaction fee for providing the relay service.

## Permit

The Dai permit function allows a spender to move funds from a user wallet by having the user sign an approval message, rather than an approval transaction on the Ethereum blockchain, which eliminates the initial gas cost of approval. The signed approval message can then be broadcasted by a relayer.

By having the permit function use the EIP712 standard, it can sign structured typed data. This allows developers to create transactions that do not simply allow a transfer of tokens from one address to another, but also transactions that involve more complicated smart contract function calls. With the permit function, as an example, now you can exchange your Dai token to another one on Uniswap without the need to have Ether in your wallet to pay for gas.

### The Typed Signed Data standard

Using EIP712, when signing data with your wallet, you will see a JSON like format of the data in your wallet approval window. This enables you to understand what data you are signing.

### Permit in the Dai contract

Constructing the permit function requires some extra parameters defined by the EIP712 standard. These parameters are required for protecting the transaction from a replay attack. This is important as many function calls in smart contracts could have the same signature, so having some parameters that differentiate a signature from another is paramount.

Hence, you might notice some extra variables that are needed in constructing the [permit function](https://github.com/makerdao/dss/blob/master/src/dai.sol#L118).

Below variables are defined in the Dai token contract:

- `chainId`: The ID of the network the contract is deployed. For Mainnet it is 1, for Kovan it is 42.
- `version:` The contract version
- `nonce:` The nonce of the last permit transaction of a user’s wallet.

This variable is defined during function construction:

- `expiry`: How long is the permit function available to be executed. Set in seconds.

The above parameters are verified when calling the permit function in the Dai token contract with the `DOMAIN_SEPARATOR`

The `v`, `r`, and `s` parameters are the result of the cryptographic signature performed when a message is signed. These parameters are used in verifying the signer of the message in the permit function in the Dai token contract.

#### Note on security

With all the aforementioned parameters for signing the permit function, the user is protected against major malicious acts from the relayers or facilitating smart contracts.
With the addition of the expiry variable, you are minimizing the risk of the relayer taking the signed message hostage and not broadcast it to the network. In case this relayer does behave maliciously, he would only be able to keep the message until the expiry value has been reached.  
Another important aspect is to verify the contracts that you are giving allowance to use your funds. If there’s a malicious entry in that contract that could take advantage of a function that has an allowance to use your funds, you are at risk of losing them.

#### Example with web3js

Let’s look at a simple example where you approve another EOA (externally owned account) to withdraw Dai from your wallet with web3.js and the Dai token contract on Kovan.

Make sure you have:

- [Metamask plugin](https://metamask.io/) installed
- Kovan ETH (get ETH from [https://faucet.kovan.network/](https://faucet.kovan.network/))
- Kovan Dai (get Dai from [https://oasis.app/borrow?network=kovan](https://oasis.app/borrow?network=kovan) using ETH)

### Create signed message with web3js

Define permit function parameters

```javascript
const SECOND = 1000;

const fromAddress = "0x9EE5e175D09895b8E1E28c22b961345e1dF4B5aE";
// JavaScript dates have millisecond resolution
const expiry = Math.trunc((Date.now() + 120 * SECOND) / SECOND);
const nonce = 1;
const spender = "0xE1B48CddD97Fa4b2F960Ca52A66CeF8f1f8A58A5";
```

Define helper function to stringify the message data

```javascript
const createPermitMessageData = function () {
  const message = {
    holder: fromAddress,
    spender: spender,
    nonce: nonce,
    expiry: expiry,
    allowed: true,
  };

  const typedData = JSON.stringify({
    types: {
      EIP712Domain: [
        {
          name: "name",
          type: "string",
        },
        {
          name: "version",
          type: "string",
        },
        {
          name: "chainId",
          type: "uint256",
        },
        {
          name: "verifyingContract",
          type: "address",
        },
      ],
      Permit: [
        {
          name: "holder",
          type: "address",
        },
        {
          name: "spender",
          type: "address",
        },
        {
          name: "nonce",
          type: "uint256",
        },
        {
          name: "expiry",
          type: "uint256",
        },
        {
          name: "allowed",
          type: "bool",
        },
      ],
    },
    primaryType: "Permit",
    domain: {
      name: "Dai Stablecoin",
      version: "1",
      chainId: 42,
      verifyingContract: "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa",
    },
    message: message,
  });

  return {
    typedData,
    message,
  };
};
```

Define signing function that will use the EIP712 for signing the message data and provide the `r`,`s`, and `v` values.

```javascript
const signData = async function (web3, fromAddress, typeData) {
  const result = await web3.currentProvider.sendAsync({
    id: 1,
    method: "eth_signTypedData_v3",
    params: [fromAddress, typeData],
    from: fromAddress,
  });
  
  const r = result.result.slice(0, 66);
  const s = "0x" + result.result.slice(66, 130);
  const v = Number("0x" + result.result.slice(130, 132));
  
  return { v, r, s };
};
```

Define the function to be invoked when creating the permit signature. This function uses the above defined helper functions to create the signature. The signature created from this function can then be sent to a relayer that will relay the transaction on chain. This relayer can be a simple wallet address with Ether or a server that provides API endpoints for retrieving signatures and relaying the transactions for a fee.

```javascript
export const signTransferPermit = async function () {
  const messageData = createPermitMessageData();
  const sig = await signData(web3, fromAddress, messageData.typedData);
  return Object.assign({}, sig, messageData.message);
};
```

Result from `signTransferPermit`

You can get this data by doing a console.log of the function

```javascript
allowed: true;
expiry: 1589205127399;
holder: "0x9EE5e175D09895b8E1E28c22b961345e1dF4B5aE";
nonce: 1;
r: "0xc225220de6c6f5a829c07bf07444435619c98ac95fb5ce82205bc9be1def858b";
s: "0x5924bfb22181c58e4ec4bc26d42ae5b4edb53ffebf9045cad2e275baab4915ba";
spender: "0xE1B48CddD97Fa4b2F960Ca52A66CeF8f1f8A58A5";
v: 27;
```

### Relay transaction with another wallet account from your Metamask account

Using the signed data from above, now you can relay the user’s transaction by calling the `Dai.permit()` function from your second Metamask wallet address.  
For simplicity, this will be shown through etherscan’s [write contract feature](https://kovan.etherscan.io/address/0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa#writeContract).

Connect to to your second Metamask wallet account and make sure you are connected to Etherscan  
![etherscan image](https://lh3.googleusercontent.com/UUJ2oY3onmx6sQlGPcQOQQg6bBWJQExE9tWJ-hLMGUkKUcT1iUDGKlqNVHHXrZngcut6-RiPcstUhDNiP1Z5EglXjXqJSb10Ng_ZKqYD9Cg2nZ1W8Be7H3Meo0LX94D0TfYlPv4)

Fill the permit function with the right parameters from the `signTransferPermit()` result above.

![etherscan image](https://lh3.googleusercontent.com/qSDkUYxiIvr5IsQO_M1tB991L1SSiWNHT0LFFJQvpz17FsxYsJk_Snnyc_RlNdYOlx_1LbMPerUQbJxmpx7pS-x4a0kGOqQHgI6qZeyqeqthbdPOlomYCDfVDchV44U2uZQXVLE)

Widraw Dai amount from aprover account with your second wallet account.

After relaying the permit transaction, the second account can now withdraw Dai from the first account. This can be done by calling the `Dai.transferFrom()` or `Dai.pull()` functions.

This simple example shows you the fundamentals of this permit function. Here, a second wallet account acted as a relayer to broadcast the signed message on the Ethereum blockchain. A true use case is to have a separate entity/service that will do this relay job for you for a small fee.

### Transfers

In order to implement a complete metatransaction, you will have to deploy a contract that implements the permit feature. This contract, when called, will check for the permit approval from the sender and then pull funds from the sender to the receiver with the `transferFrom` function. The sender needs to give approval to the contract to take funds from his wallet by signing a message with the permit function. The actual invoker of the transfer transaction will be a relayer service that listens for incoming signed messages with the respective function call.

A community implementation example of this can be found in the code base of [https://stablecoin.services/](https://stablecoin.services/). **Note: We are simply using this implementation as an example and should not be taken as endorsed code that can be mimicked for production usage.** This service utilizes a relayer service and smart contracts that allows for transferring your Dai and using other services in a gasless manner.  
The [Dai Automated Clearing House (DACH)](https://etherscan.io/address/0x64043a98f097fD6ef0D3ad41588a6B0424723b3a#code) contract implements the gasless transfer function, specifically the [daiCheque](https://github.com/dapphub/ds-dach/blob/49a3ccfd5d44415455441feeb2f5a39286b8de71/src/dach.sol#L114) function. In order for this function to be successful, it has to verify the permit signature the user signed. The user has to give permission to this contract to pull funds from his wallet to transfer to the receiver and also transfer the fee to the relayer that will broadcast the transaction on the Ethereum network.

In the `daiCheque` function, the user will:

- Sign a permit function to approve the DACH contract.

- Have the permit signature broadcasted on the Ethereum network

- Sign the daiCheque function

- Have the daiCheque signature broadcasted on the Ethereum network.

In this situation, the user will have to broadcast both of the signatures individually onto the network.

To solve they need to broadcast two signatures individually, Stablecoin Services have developed a [helper contract](https://etherscan.io/address/0x3238695287924b4b5a32d71653fc6c26b03b5209#code) that implements both permit and transfer signatures in one transaction.  
The function is also called [daiCheque](https://github.com/dapphub/ds-dach/blob/49a3ccfd5d44415455441feeb2f5a39286b8de71/src/withPermit.sol#L57), but is modified to implement the Dai.permit() function as well. In other words, a cheque with permit function. This way, the user will sign the approval to allow the DACH contract pull funds from his wallet through the Dai.permit() function and also sign the transferFrom function to allow the transfer of funds to the receiver. Both signatures will be broadcasted onto the Ethereum network by the relayer.

### Relaying to Ethereum Network

After signing the permit and daiCheque functions, now you can send them to a relay server to broadcast those transactions onto the Ethereum network. Stablecoin Services have implemented a [relayer](https://github.com/MrChico/stablecoin.services/blob/master/api-doc.md#v1daichequewithpermit) that can help you broadcast your signed messages. This relayer takes a fee for doing the broadcasting.

This relayer is a server that accepts API calls for different functions. All calls are done at this endpoint: [https://api.stablecoin.services](https://api.stablecoin.services/).

In the [daiCheque](https://github.com/dapphub/ds-dach/blob/49a3ccfd5d44415455441feeb2f5a39286b8de71/src/dach.sol#L114) function there’s a fee transfer to the relayer as well, `dai.transferFrom(sender,relayer,fee)`, this fee can be calculated by calling the [/v1/daiChequeWithPermit/fee](https://github.com/MrChico/stablecoin.services/blob/master/api-doc.md#v1chaichequewithpermitfee) if you haven’t signed the permit before or calling [/v1/chaiCheque/fee](https://github.com/MrChico/stablecoin.services/blob/master/api-doc.md#v1daichequefee) if you signed permit before and just wish to transfer Dai.  
The server would return a JSON like response with the fee formatted in wei:

```JSON
{
    "success": "true",
    "message": 911480649973500000
}
```

This fee is then added in the construction of the signing message before it being sent to the relay server for broadcasting. Once broadcasted, this fee is then deposited into the relayer’s account for providing the relay service.

To broadcast the message, make a POST api call at [/v1/daiChequeWithPermit](https://github.com/MrChico/stablecoin.services/blob/master/api-doc.md#v1daichequewithpermit) with the permit and daiCheque signatures. Check [this example](https://github.com/MrChico/stablecoin.services/blob/master/ui/src/utils/apiUtils.js#L30) from Stablecoin Services.

It is up to the relayer service to decide how much to charge for a gasless transaction in addition to the Ethereum network fee. The permit function does not include the fee payment by default.

This allows the relayer to define the fee structure in relaying the signed messages.

## Notes on Gas Station Network

[Gas Station Network](https://www.opengsn.org/) is one of the first attempts at creating gasless transactions. Their architecture allows relayers to only accept Ether for gas as there is no provision for them to directly accept Dai. Users can still pay fees in Dai when they use a Token Paymaster contract that brings additional liquidity risk when converting Dai through Uniswap.

In addition, the entire user Dai balance will be at risk while swapping some Dai for Eth to pay fees because users can only set an unlimited balance approval to the Token Paymaster contract using the permit.

If the gasless contract operator wants to avoid this fee conversion using Uniswap, they need to maintain an ETH balance in GSN.

## Summary

In this guide we have shown you the building blocks of the Dai permit function and how it can be used for creating gasless transactions through the Stablecoin Services Dai Automated Clearing House contract and its relayer server.

## Additional Resources

- [Dai Automated Clearing House (DACH) contracts](https://github.com/dapphub/ds-dach/tree/49a3ccfd5d44415455441feeb2f5a39286b8de71)

- [Stablecoin services relayer API](https://github.com/MrChico/stablecoin.services/blob/master/api-doc.md)

- [Mosendo’s Gasless Dai implementation](https://medium.com/mosendo/gasless-by-mosendo-3030f5e99099)

## Help

For any questions reach us at:

- #dev channel in [chat.makerdao.com](https://chat.makerdao.com/)
