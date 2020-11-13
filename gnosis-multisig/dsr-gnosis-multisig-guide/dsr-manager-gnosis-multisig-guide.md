# Add Dai to DSR through DsrManager with Gnosis Multisig

**Level:** Advanced  
**Estimated Time:** 20 minutes

- [Add Dai to DSR through DsrManager with Gnosis Multisig](#add-dai-to-dsr-through-dsrmanager-with-gnosis-multisig)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Step 1: Approve DsrManager to pull funds](#step-1-approve-dsrmanager-to-pull-funds)
  - [Step 2: Add Dai to DSR](#step-2-add-dai-to-dsr)
  - [Step 3: Retrieve Dai from DSR](#step-3-retrieve-dai-from-dsr)
    - [3.A - Retrieve a portion of Dai from DSR](#3a---retrieve-a-portion-of-dai-from-dsr)
    - [3.B - Retrieve all Dai from DSR](#3b---retrieve-all-dai-from-dsr)
  - [Additional Resources](#additional-resources)
  - [Help](#help)

## Overview

In this guide, we will cover how you can add Dai from the old version of the Gnosis Multisig Wallet, to the DSR, and retrieve it again through the DsrManager contract.

## Learning Objectives

- Learn how to safely move Dai funds from Gnosis Multisig Wallet into the DSR contract of Maker Protocol through [DsrManager contract](https://etherscan.io/address/0x373238337Bfe1146fb49989fc222523f83081dDb#code).

- Learn how to retrieve Dai and earned savings back into Gnosis Multisig Wallet.

## Pre-requisites

- Basic knowledge of how to execute multisig transactions in the Gnosis Multisig UI.

## Step 1: Approve DsrManager

Go to [https://wallet.gnosis.pm](https://wallet.gnosis.pm) and login with your wallet. This is the old version of Gnosis Multisig.

Navigate to the “Wallets” page, and click on the specific multisig wallet name, to enter the user interface for the specific multisig wallet.

In order to be able to add Dai to DSR, we must first have to approve DsrManager to pull funds from your multisig wallet. To approve, you need to approve the DsrManager contract in the Dai token contract.

Approve DsrManager through the multisig user interface

- Under “Multisig transactions” press “Add”
- In the “Destination” field input the address of Dai Token contract: `0x6B175474E89094C44Da98b954EedeAC495271d0F`
- In the “ABI string” window copy and insert the entire ABI from this link: [https://api.etherscan.io/api?module=contract&action=getabi&address=0x6b175474e89094c44da98b954eedeac495271d0f&format=raw](https://api.etherscan.io/api?module=contract&action=getabi&address=0x6b175474e89094c44da98b954eedeac495271d0f&format=raw)
- In the “Method” dropdown select the “approve” method.
- This will generate two input fields below: “usr” and “wad”
- In “usr” you copy paste the address of the DsrManager contract - `0x373238337Bfe1146fb49989fc222523f83081dDb`
- In “wad” you write the amount of Dai you want to allow DsrManager to pull from your wallet. To allow it to withdraw any size of Dai, set “wad” to `-1`. If you want a certain number, set “wad” to your number plus the 18 zero decimals after. For 10 Dai, you’ll input `10000000000000000000`.
- Press “Send multisig transaction.”
- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
- Once the transaction has been mined, you can continue to step 2.

## Step 2: Add Dai to DSR

- Under “Multisig transactions” press “Add”
- In the “Destination” field input the address of DsrManager contract: `0x373238337Bfe1146fb49989fc222523f83081dDb`
- In the “ABI string” field, copy and insert the entire ABI from this link: [https://api.etherscan.io/api?module=contract&action=getabi&address=0x373238337Bfe1146fb49989fc222523f83081dDb&format=raw](https://api.etherscan.io/api?module=contract&action=getabi&address=0x373238337Bfe1146fb49989fc222523f83081dDb&format=raw)
- In the “Method” dropdown, select the “join” method.
- This will generate two input fields: “dst” and “wad”.
- In “dst”, copy paste your multisig wallet address.
- In “wad”, write the amount of Dai you want to lock in DSR. For example, locking in 10 Dai, you’ll paste in `10000000000000000000`. Make sure to add 18 zeros, as the token has 18 decimal places.
- Press “Send multisig transaction”. This is a gas intensive transaction, so make sure to set a higher gas limit - try with 400000.
- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
- Once the transaction has been mined the Dai should be added to DSR.

You can verify by pasting your multisig wallet address in the `pieOf` [contract field of DsrManager](https://etherscan.io/address/0x373238337bfe1146fb49989fc222523f83081ddb#readContract). It will return a number a little lower than what you added, since this is the normalized internal balance of DSR. To get your Dai balance you must multiply this number with Chi. As long as this is a non-zero number you should be good to go.

## Step 3: Retrieve Dai from DSR

There are two options to retrieve your Dai from DSR. You could retrieve it all at once or just retrieve a portion of it.

### 3.A - Retrieve a portion of Dai from DSR

- Under “Multisig transactions” press “Add”
- In the “Destination” field input the address of DsrManager contract: `0x373238337Bfe1146fb49989fc222523f83081dDb`
- In the “ABI string” field, copy and insert the entire ABI from this link: [https://api.etherscan.io/api?module=contract&action=getabi&address=0x373238337Bfe1146fb49989fc222523f83081dDb&format=raw](https://api.etherscan.io/api?module=contract&action=getabi&address=0x373238337Bfe1146fb49989fc222523f83081dDb&format=raw)
- In the “Method” dropdown select the “exit” method.
- This will generate two fields: “dst” and “wad”.
- In “dst”, copy paste your multisig wallet address.
- In “wad”, write the amount of Dai you want to retrieve from DSR. To withdraw 5 Dai, you set “wad” to: `5000000000000000000`. Make sure to add 18 zeros, as the token has 18 decimal places.
- Press “Send multisig transaction”. This is also a gas intensive transaction, so make sure to set a higher gas limit - try with `400000`.
- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
- Once the transaction has been mined the Dai should be in your multisig wallet.

### 3.B - Retrieve all Dai from DSR

- Under “Multisig transactions” press “Add”
- In the “Destination” field input the address of DsrManager contract: `0x373238337Bfe1146fb49989fc222523f83081dDb`
- In the “ABI string” field, copy and insert the entire ABI from this link: [https://api.etherscan.io/api?module=contract&action=getabi&address=0x373238337Bfe1146fb49989fc222523f83081dDb&format=raw](https://api.etherscan.io/api?module=contract&action=getabi&address=0x373238337Bfe1146fb49989fc222523f83081dDb&format=raw)
- In the “Method” dropdown select the “exitAll” method.
- This will generate one field: “dst”.
- In “dst”, copy paste your multisig wallet address.
- Press “Send multisig transaction”. This is also a gas intensive transaction, so make sure to set a higher gas limit - try with 400000.
- The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
- Once the transaction has been mined the Dai should be in your multisig wallet.

## Additional Resources

- [DSR Integration Guide](https://github.com/makerdao/developerguides/blob/master/dai/dsr-integration-guide/dsr-integration-guide-01.md)

## Help

- [chat.makerdao.com - #dev channel](https://chat.makerdao.com/channel/dev)
