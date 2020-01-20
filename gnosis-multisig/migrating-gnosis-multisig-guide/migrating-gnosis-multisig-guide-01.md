# Migrating from Sai to Dai through Gnosis Multisig

**Level:** Intermediary
**Estimated Time:** 30 minutes

## Overview
In this guide, we will cover how you can migrate from Sai to Dai using the old version of the Gnosis Multisig Wallet.

## Pre-requisites

-   Basic knowledge of how to execute multisig transactions in the Gnosis Multisig UI.

## Step 1: Approving the migration contract to move Sai from the multisig to migration contract contract

 - Go to [https://wallet.gnosis.pm/](https://wallet.gnosis.pm/) and login with your wallet. This is the old version of Gnosis Multisig.
  
- Navigate to the “Wallets” page, and click on the specific multisig wallet name, to enter the user interface for the specific multisig wallet. To make sure you have done this correctly, test it out with a small amount of Sai to begin with, i.e. 1 Sai.


-   Under “Multisig transactions” press “Add”
    
-   In the “Destination” field input the address of the Sai token: 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359
    
-   In the “ABI string” window copy and insert the entire ABI text string from the link below: [http://api.etherscan.io/api?module=contract&action=getabi&address=0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359&format=raw](http://api.etherscan.io/api?module=contract&action=getabi&address=0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359&format=raw)
    
-   In the “Method” dropdown select the “approve” method.
    

-   This will generate two input fields below: “usr” and “wad”
    
-   In “usr” you copy/paste the address of the migration contract:

0xc73e0383f3aff3215e6f04b0331d58cecf0ab849

-   In “wad” you enter the amount of Dai you want to let the contract move for you, and add 18 0’s after the number, due to the token having 18 decimal spaces. So if you want to approve 1 Sai, you need to input 1000000000000000000
    
-   Press “Send multisig transaction.”
    

-   The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
    
-   Once the transaction has been mined you can continue to step 2.
    

## Step 2: Migrating Sai to Dai

-   Under “Multisig transactions” press “Add”
    
-   In the “Destination” field input the address of the migration contract:
    

0xc73e0383f3aff3215e6f04b0331d58cecf0ab849

  

-   In the “ABI string” window copy and insert the entire ABI text string from the link below: [http://api.etherscan.io/api?module=contract&action=getabi&address=0xc73e0383f3aff3215e6f04b0331d58cecf0ab849&format=raw](http://api.etherscan.io/api?module=contract&action=getabi&address=0xc73e0383f3aff3215e6f04b0331d58cecf0ab849&format=raw)
    
-   In the “Method” dropdown select the “swapSaiToDai” method.
    

-   This will generate the input field “wad”.
    
-   In “wad” you enter the amount of Sai you want to let the contract migrate to Dai for you, and add 18 0’s after the number, due to the token having 18 decimal spaces. So if you want to approve 1 Dai, you need to input 1000000000000000000
    
-   Press “Send multisig transaction.”
    
-   This function is quite gas intensive, so try with a 500000 gas limit.
    

-   The other key holders must now confirm this transaction, and once the quorum is reached, a keyholder can execute the transaction.
    
-   Once the transaction has been mined the Sai should have been migrated to Dai.
    
-   You can verify by checking the Dai balance of the multisig wallet.

## Additional resources

-  [MCD Upgrade guide]([https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/upgrading-to-multi-collateral-dai.md](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/upgrading-to-multi-collateral-dai.md))

## Help

-   Contact Integrations team -  [integrate@makerdao.com](mailto:integrate@makerdao.com)
-   Rocket chat - #dev channel