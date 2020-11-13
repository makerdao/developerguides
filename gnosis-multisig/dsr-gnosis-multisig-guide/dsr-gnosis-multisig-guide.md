# Activating Dai Savings Rate on Dai stored in Gnosis Multisig Wallet

**Level:** Advanced  
**Estimated Time:** 30 minutes

- [Activating Dai Savings Rate on Dai stored in Gnosis Multisig Wallet](#activating-dai-savings-rate-on-dai-stored-in-gnosis-multisig-wallet)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Step 1: Building a DS-Proxy contract for the Multisig](#step-1-building-a-ds-proxy-contract-for-the-multisig)
    - [1.A Create a DS-Proxy for the multisig using Seth](#1a-create-a-ds-proxy-for-the-multisig-using-seth)
    - [1.B Create a DS-Proxy for the multisig through the multisig user interface](#1b-create-a-ds-proxy-for-the-multisig-through-the-multisig-user-interface)
  - [Step 2: Approving DS-Proxy to send Dai from Multisig to DSR contract](#step-2-approving-ds-proxy-to-send-dai-from-multisig-to-dsr-contract)
  - [Step 3: Adding Dai to DSR](#step-3-adding-dai-to-dsr)
  - [Step 4: Retrieving Dai from DSR](#step-4-retrieving-dai-from-dsr)
  - [Additional resources](#additional-resources)
  - [Help](#help)

## Overview

In this guide, we will cover how you can add Dai from the old version of the Gnosis Multisig Wallet, to the DSR, and retrieve it again.

## Learning Objectives

- Learn how to safely move funds from Gnosis Multisig Wallet into the DSR contract of the Maker Protocol.

- Learn how to retrieve Dai and earned savings back into Gnosis Multisig Wallet.

## Pre-requisites

- Basic knowledge of how to execute multisig transactions in the Gnosis Multisig UI.

- Knowledge of [Seth - an Ethereum CLI tool](#https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md)

## Step 1: Building a DS-Proxy contract for the Multisig

Go to [https://wallet.gnosis.pm/](https://wallet.gnosis.pm/) and login with your wallet. This is the old version of Gnosis Multisig.

Navigate to the “Wallets” page, and click on the specific multisig wallet name, to enter the user interface for the specific multisig wallet.

In order to be able to add Dai to DSR, we must first have a DS-Proxy contract created for the multisig wallet to allow us to interact with the Maker Protocol.  

If the multisig wallet already has a DS-Proxy contract deployed, you can retrieve the contract address by using the following seth commands in a terminal ([if you are unfamiliar with seth, go through this guide first](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md)):

`export PROXY_REGISTRY=0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4`

`export MULTISIG=<insert multisig wallet address here>`

`seth call $PROXY_REGISTRY 'proxies(address)(address)' $MULTISIG`

If this returns 0, then there is no DS-Proxy deployed, and you must follow the steps below to create one. Follow either step 1.A or 1.B.

### 1.A Create a DS-Proxy for the multisig using Seth

In a terminal use the following commands to create DS-Proxy for the multisig.

`export PROXY_REGISTRY=0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4`

`export MULTISIG=<insert multisig wallet address here>`

`seth send $PROXY_REGISTRY 'build(address)' $MULTISIG`

Once the transaction has been mined, you should be able to retrieve the DS-Proxy address with the following command:

`seth call $PROXY_REGISTRY 'proxies(address)(address)' $MULTISIG`

### 1.B Create a DS-Proxy for the multisig through the multisig user interface

- Under “Multisig transactions” press “Add”

- In the “Destination” field input the address of ProxyRegistry contract: 0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4

- In the “ABI string” window copy and insert the entire ABI from this link: [http://api.etherscan.io/api?module=contract&action=getabi&address=0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4&format=raw](http://api.etherscan.io/api?module=contract&action=getabi&address=0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4&format=raw)
- In the “Method” dropdown select the first “build” method - there are two “build” options, this one will take no parameters.
- Press “Send multisig transaction.”

Other key holders must now approve this transaction - once it has been approved by they keyholders, a keyholder must execute the function by pressing “Execute” next to the transaction. It can be a gas heavy transaction to build a proxy, so make sure you pass on a gas limit of 400000.

- We need to know the address of this DS-Proxy contract before we can continue. You can navigate to the transaction on Etherscan by inputting the transaction hash of the transaction that was submitted when a keyholder pressed “Execute” into the search bar.
- On Etherscan you can navigate to “Internal transactions and under the type trace "create_0_0_0" you should see a “To” address, which is the proxy contract.

- Verify by navigating to this contract address, clicking on “Contract”, and see that it is in fact a DS-Proxy contract, by verifying the “Contract Name” field. Save the address for this contract.

You can also use the command-line tool seth to retrieve this contract address.

Execute the following commands in a terminal:

`export PROXY_REGISTRY=0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4`

`export MULTISIG=<insert multisig wallet address here>`

`seth call $PROXY_REGISTRY 'proxies(address)(address)' $MULTISIG`

This should return a string, for example `401f9073f99bd9577c68399c89f270d46e80b65d`

You need to add a “0x” in front so it is for example: `0x401f9073f99bd9577c68399c89f270d46e80b65d`

Save this DS-Proxy contract address as we will need it later.

## Step 2: Approving DS-Proxy to send Dai from Multisig to DSR contract

- Under “Multisig transactions” press “Add”
- In the “Destination” field input the address of the Dai token: `0x6b175474e89094c44da98b954eedeac495271d0f`
- In the “ABI string” window copy and insert the entire ABI text string from the link below: [http://api.etherscan.io/api?module=contract&action=getabi&address=0x6b175474e89094c44da98b954eedeac495271d0f&format=raw](http://api.etherscan.io/api?module=contract&action=getabi&address=0x6b175474e89094c44da98b954eedeac495271d0f&format=raw)
- In the “Method” dropdown select the “approve” method.
- This will generate two input fields below: “usr” and “wad”
- In “usr” you copy paste the address of the DS-Proxy contract we created at the end of step 1.
- In “wad” you enter the amount of Dai you want to let the contract move for you, and add 18 0’s after the number, due to the token having 18 decimal spaces. So if you want to approve 1 Dai, you need to input `1000000000000000000`
- You can also input `-1` to simply allow any size Dai transaction for the future.
- Press “Send multisig transaction.”

- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
- Once the transaction has been mined you can continue to step 3.

## Step 3: Adding Dai to DSR

- Under “Multisig transactions” press “Add”

- In the “Destination” field input the address of the DS-Proxy contract we created at the end of step 1.
- In the “ABI string” window copy and insert the entire ABI text string from the link below: [http://api-kovan.etherscan.io/api?module=contract&action=getabi&address=0xD0bf0b956f570CdfC0e06f032BfAa0Dc206C56c7&format=raw](http://api-kovan.etherscan.io/api?module=contract&action=getabi&address=0xD0bf0b956f570CdfC0e06f032BfAa0Dc206C56c7&format=raw)
- In the “Method” dropdown select the first “execute” method.
- This will generate to input fields below: **“_target”** and **“_data”**
- In **“_target”** input the contract address of DssProxyActionsDsr: `0x07ee93aeea0a36fff2a9b95dd22bd6049ee54f26`
- In “data” we need to use Seth to create the ABI encoded call data.
- In a terminal post the following commands:

`export POT=0x197e90f9fad81970ba7976f33cbd77088e5d7cf7`

`export DAIJOIN=0x9759a6ac90977b93b58547b4a71c78317f391a28`

`seth calldata 'join(address,address,uint)' $DAIJOIN $POT $(seth --to-uint256 $(seth --to-wei insert amount of Dai here eth))`

- In the command above, in the `<insert amount of Dai here>` you simply pass on the amount you granted approval for in step 2. So if you granted approval for 1000 Dai, you just input 1000 in the above command. For example:

`seth calldata 'join(address,address,uint)' $DAIJOIN $POT $(seth --to-uint256 $(seth --to-wei 1000 eth))`

- This should return a text string in the terminal, which you must copy paste into the “_data” field in the “Send multisig transaction” user interface.

- Example of what a string could look like:

`0x9f6c3dbd0000000000000000000000005aa71a3ae1c0bd6ac27a1f28e1415fffb6f15b8c000000000000000000000000ea190dbdc7adf265260ec4da6e9675fd4f5a78bb0000000000000000000000000000000000000000000000008ac7230489e80000`

- Press “Send multisig transaction.”
- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction. This is also a gas intensive transaction, so make sure to set a higher gas limit - try with 400000.
- Once the transaction has been mined the Dai should be added to DSR.

You can verify by inserting the address of the multisig wallet into the search bar of [dsr.fyi](https://dsr.fyi/).

You can also verify by navigating to the DSR contract on Etherscan here: [https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#readContract](https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#readContract)

Under “Read Contract”, function 5. “Pie” you can insert the DS-Proxy contract address from step 1. It will return a number a little lower than what you added, since this is the normalized internal balance of DSR. To get your Dai balance you must multiply this number with Chi. As long as this is a non-zero number you should be good to go.

## Step 4: Retrieving Dai from DSR

- Under “Multisig transactions” press “Add”
- In the “Destination” field input the address of the DS-Proxy contract we created at the end of step 1.
- In the “ABI string” window copy and insert the entire ABI text string from the link below: [http://api-kovan.etherscan.io/api?module=contract&action=getabi&address=0xD0bf0b956f570CdfC0e06f032BfAa0Dc206C56c7&format=raw](http://api-kovan.etherscan.io/api?module=contract&action=getabi&address=0xD0bf0b956f570CdfC0e06f032BfAa0Dc206C56c7&format=raw)
- In the “Method” dropdown select the first **“execute”** method.
- This will generate to input fields below: **“_target”** and **“_data”**
- In “_target” input the contract address of DssProxyActionsDsr: `0x07ee93aeea0a36fff2a9b95dd22bd6049ee54f26`
- In **“data”** we need to use Seth to create the ABI encoded call data.
- A) If you want to retrieve all Dai in DSR utilize the following seth commands in a terminal to create the data.

`export POT=0x197e90f9fad81970ba7976f33cbd77088e5d7cf7`

`export DAIJOIN=0x9759a6ac90977b93b58547b4a71c78317f391a28`

`seth calldata 'exitAll(address,address)' $DAIJOIN $POT`

- This should return this string, which should always be the same, so verify that you get the same exact string:

`0xc77843b30000000000000000000000009759a6ac90977b93b58547b4a71c78317f391a28000000000000000000000000197e90f9fad81970ba7976f33cbd77088e5d7cf7`

- B) If you just want to retrieve a specific amount, you must utilize the following seth commands in a terminal to create the data:

`export POT=0x197e90f9fad81970ba7976f33cbd77088e5d7cf7`

`export DAIJOIN=0x9759a6ac90977b93b58547b4a71c78317f391a28`

`seth calldata 'exit(address,address,uint)' $DAIJOIN $POT $(seth --to-uint256 $(seth --to-wei insert amount of Dai here eth))`

To create the data for a transfer of 10,000 Dai the last commands would thus be

`seth calldata 'exit(address,address,uint)' $DAIJOIN $POT $(seth --to-uint256 $(seth --to-wei 10000 eth))`

- Copy paste the string for retrieving all Dai, or a specific amount of Dai depending on which of option A) and B) you chose above, into the “_data” field in the “Send multisig transaction” user interface.

- Press “Send multisig transaction.”
- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction. This is also a gas intensive transaction, so make sure to set a higher gas limit - try with 400000.
- Once the transaction has been mined the Dai should be retrieved from DSR.

You can verify by inserting the address of the multisig wallet into the search bar of [dsr.fyi](https://dsr.fyi/).

You can also verify by navigating to the DSR contract on Etherscan here: [https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#readContract](https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#readContract)

Under “Read Contract”, function 5. “Pie” you can insert the DS-Proxy contract address from step 1. It will return a number a little lower than what you should have left or 0 if you retrieved it all, since this is the normalized internal balance of DSR. To get your Dai balance you must multiply this number with Chi. As long as this is a number close to what you would expect you should be good to go.

## Additional resources

- [DSR Integration Guide](https://github.com/makerdao/developerguides/blob/master/dai/dsr-integration-guide/dsr-integration-guide-01.md)

## Help

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel
