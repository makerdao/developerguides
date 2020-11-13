---
title: How to build a Dai.js wallet plugin
description: Learn how to integrate your wallet into the Dai.js library
parent: dai.js
tags:
  - dai.js
  - wallet
  - integrate
  - wallet plugin
slug: how-to-build-a-dai-js-wallet-plugin
contentType: guides
root: false
---

# How to build a Dai.js wallet plugin

**Level:** Intermediate  
**Estimated Time:** 30 - 45 min

- [How to build a Dai.js wallet plugin](#how-to-build-a-daijs-wallet-plugin)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Sections](#sections)
    - [Understand Dai.js wallet provider requirements](#understand-daijs-wallet-provider-requirements)
  - [Examples of partners integrating with the plugin](#examples-of-partners-integrating-with-the-plugin)
    - [Tier 1](#tier-1)
    - [Tier 2](#tier-2)
    - [Tier 3](#tier-3)
  - [Front-End Dai.js plugin implementation](#front-end-daijs-plugin-implementation)
  - [Summary](#summary)
  - [Additional Resources](#additional-resources)
  - [Help](#help)

## Overview

This guide will walk you through building your own Dai.js plugin that integrates a wallet provider. There are many wallet providers out there, and in order for these wallet providers to interact with the Maker suite of dapps (oasis.app, governance dashboard, migration app), they have to integrate through the Dai.js SDK. As this SDK is used in the Maker dapps, your wallet can be used to interact with the Maker Protocol.

## Learning Objectives

Here you’ll learn how to integrate your wallet into the Dai.js SDK by creating a Dai.js wallet plugin.

- Understand Dai.js wallet provider requirements
- Example of partners integrating with the plugin
- Front-End Dai.js plugin implementation

## Pre-requisites

Knowledge in:

- [Web3 wallets](https://ethereum.org/use/#3-what-is-a-wallet-and-which-one-should-i-use)
- Javascript
- [Dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki)

## Sections

### Understand Dai.js wallet provider requirements

There are a few types of plugins the Dai.js SDK can accept or parse through. One type we are going to use in this guide is a **callback function**. This callback function needs to pass to the SDK an object with properties such as **subprovider**, user’s wallet **address** and in some cases a **handleRequest** function from the provided wallet plugin.

To start with, below you’ll see an example of how you can structure your **index.js** file in your plugin repository. This is the core function that needs to be in your index.js file. In addition, you’ll have to add extra logic from your own wallet provider to fill the below function’s requirements.

```javascript
export  default  function(maker) {

    const  MYWALLETNAME = 'mywalletname';
    maker
    .service('accounts', true)
    .addAccountType(MYWALLETNAME, settings => {
    // YOUR WALLET PROVIDER LOGIC
    // Invoke the web3 provider from the wallet - subprovider
    // Get user's wallet address
    return {subprovider, address}
    })

}
```

The above example is a function that takes a callback function as its parameter that will invoke the logic for providing the subprovider and address to the Dai.js SDK.

When this function is invoked in the SDK, it can access different kinds of services the SDK provides. Invoking a service in Dai.js is done by calling the [service()](https://github.com/makerdao/dai.js/blob/dev/packages/dai/src/Maker.js#L67) function with the desired service name you require. In this example, the callback function will use the accounts service to add a new account type by using the [addAccountType()](https://github.com/makerdao/dai.js/blob/dev/packages/dai/src/eth/AccountsService.js#L51) function.  
  
In this **addAccountType** function, you add two parameters. First one is the name of the account type (**MYWALLETNAME**) and the second is a callback function that will be used as a factory in the SDK.  
  
Anytime the user will choose your account type to initialise the wallet from the frontend application, the SDK will call the function to invoke the logic for connecting the third party wallet.

This is the main pattern for how to integrate a third party wallet into the Dai.js SDK. Next, you will see some examples of how different partners have integrated.

## Examples of integrating with the plugin

There are different levels of complexity with which a third wallet provider could integrate with the Dai.js SDK. The level of complexity depends on the compatibility of this third party wallet provider with the SDK. The more compatible the easier it is to integrate.  
  
The compatibility depends on the web3 provider engine. Dai.js mostly works with the [Hooked Wallet Provider](https://github.com/MetaMask/web3-provider-engine/blob/master/subproviders/hooked-wallet.js) engine from Metamask. Below, you’ll see three examples of web3 engine providers that are and aren’t compatible with the SDK and how they have been integrated. Tier 1 is the easiest example, while tier 2 and 3 grow in complexity.

### Tier 1

[WalletConnect](https://walletconnect.org/)  is an open protocol for connecting wallets to Dapps. [The Dai Plugin WalletConnect repo](https://github.com/makerdao/dai-plugin-walletconnect) contains the code logic for connecting the wallet to Dai.js.

Below you can see the code from the [index.js](https://github.com/makerdao/dai-plugin-walletconnect/blob/master/src/index.js) file:  
  
```javascript
import  WalletConnectSubprovider  from  '@walletconnect/web3-subprovider';

export  default  function(maker) {

    const  WALLETCONNECT  =  'walletconnect';
    maker
    .service('accounts', true)
    .addAccountType(WALLETCONNECT, async  settings  => {
    const  subprovider  =  new  WalletConnectSubprovider({
        bridge:  'https://bridge.walletconnect.org'
    });
    const { accounts } =  await subprovider.getWalletConnector();
    const [address] =  accounts;
    return { subprovider, address };
    });
}
```
  
As can be seen in the code example, this looks to be a straightforward solution. WalletConnect has its own web3-subprovider package that is compatible with the Dai.js SDK, which can be seen in the import:

```javascript
import  WalletConnectSubprovider  from  '@walletconnect/web3-subprovider';
```

This subprovider is then used in the main export function to invoke the connection to the user’s wallet to obtain the address and provide it in the return function.

The `subprovider` already has the default **handleRequest** function that is needed by Dai.js to invoke transactions to the user. Hence, there’s no need to define it.

### Tier 2

[Ledger Wallet](https://www.ledger.com/) - a hardware wallet provider. The [Dai Plugin Ledger Web](https://github.com/makerdao/dai-plugin-ledger-web) repo contains the logic connecting the ledger wallet to Dai.js.

Below you can see the code from the [index.js](https://github.com/makerdao/dai-plugin-ledger-web/blob/master/src/index.js) file:

```javascript
import LedgerSubProvider, { setChosenAddress } from './vendor/ledger-subprovider';
import Transport from '@ledgerhq/hw-transport-u2f';

const legacyDerivationPath = "44'/60'/0'/0/0";
const defaultDerivationPath = "44'/60'/0'";

export default function(maker) {
  maker.service('accounts', true).addAccountType('ledger', async settings => {
    const subprovider = LedgerSubProvider(() => Transport.create(), {
      // options: networkId, path, accountsLength, accountsOffset
      accountsOffset: settings.accountsOffset || 0,
      accountsLength: settings.accountsLength || 1,
      networkId: maker.service('web3').networkId(),
      path:
        settings.path ||
        (settings.legacy ? legacyDerivationPath : defaultDerivationPath)
    });

    let address;

    if (settings.accountsLength && settings.accountsLength > 1) {
      if (!settings.choose) {
        throw new Error(
          'If accountsLength > 1, "choose" must be defined in account options.'
        );
      }

      const addresses = await new Promise((resolve, reject) =>
        subprovider.getAccounts((err, addresses) =>
          err ? reject(err) : resolve(addresses)
        )
      );

      address = await new Promise((resolve, reject) => {
        const callback = (err, address) =>
          err ? reject(err) : resolve(address);

        // this chooser function allows the app using the plugin to display the
        // list of addresses to a human user and let them make a choice.
        settings.choose(
          Object.keys(addresses).map(k => addresses[k]),
          callback
        );
      });
      setChosenAddress(address);
    } else {
      address = await new Promise((resolve, reject) =>
        subprovider.getAccounts((err, addresses) =>
          err ? reject(err) : resolve(addresses[0])
        )
      );
    }

    return { subprovider, address };
  });
}
```
  
In this example, the ledger subprovider is also compatible with the Dai.js SDK. Here, the code logic seems larger but it does the same function as compared to the WalletConnect. All the extra code is for setting up the Ledger provider to extract the user’s address and pass it down in the return object.

### Tier 3

[WalletLink](https://www.walletlink.org/#/) - link your Dapp to mobile wallets.

The [Dai Plugin WalletLink](https://github.com/makerdao/dai-plugin-walletlink) contains the logic connecting walletLink to Dai.js.

Below you can see the code from the index.js file.

```javascript
import WalletLink from 'walletlink';

export default function(maker) {
  const WALLETLINK = 'walletlink';

  maker.service('accounts', true).addAccountType(WALLETLINK, async settings => {
    const web3Service = maker.service('web3');
    const CHAIN_ID = web3Service.networkId();
    const ETH_JSONRPC_URL = web3Service.rpcUrl;

    const appName = 'MCD Portal';
    const walletLink = new WalletLink({ appName });
    const walletLinkProvider = walletLink.makeWeb3Provider(
      ETH_JSONRPC_URL,
      CHAIN_ID
    );

    const accounts = await walletLinkProvider.enable();
    const address = accounts[0];
    if (settings.callback && typeof settings.callback === 'function') {
      settings.callback(address);
    }

    // setEngine and handleRequest are expected by the web3ProviderEngine
    function setEngine(engine) {
      const self = this;
      if (self.engine) return;
      self.engine = engine;
      engine.on('block', function(block) {
        self.currentBlock = block;
      });

      engine.on('start', function() {
        self.start();
      });

      engine.on('stop', function() {
        self.stop();
      });
    }

    function handleRequest(payload, next, end) {
      const self = this;
      // Including the nonce throws an error "couldn't find tx for nonce"
      if (Array.isArray(payload.params)) delete payload.params[0].nonce;
      self.sendAsync(payload, (err, result) => {
        return result ? end(null, result.result) : end(err);
      });
    }

    walletLinkProvider.setEngine = setEngine;
    walletLinkProvider.handleRequest = handleRequest;

    return { subprovider: walletLinkProvider, address };
  });
}
```
  
In this example, walletLink’s web3 provider is not compatible with Dai.js, so there were added two extra functions in the callback to wrap walletLink’s provider. These functions are **setEngine()** and **handleRequest()**. Both these functions are added as an extra property to the **walletLinkProvider** object so it can become compatible with the Dai.js SDK. These functions are used to sign transactions from the SDK.

The **setEngine()** function sets the **walletLinkProvider** as the current web3 provider in the SDK.

The **handleRequest** function is used by the SDK to invoke transactions by providing the **payload** parameter. The payload parameter holds all the necessary data for the transaction to be signed. In other words, the payload is the data for the RPC call. This data has identifiers such as: **to address**, **from address**, **gas**, **nonce** and specific function data that might be used if it’s used to call smart contracts.

Inside the **handleRequest** function, we adapt it to call the walletLink **sendAsync** function with the provided **payload** from the SDK, so walletLink could process and display the transaction to the user.

After this, we return the **walletLinkProvider** and **address** for the Dai.js SDK to consume when **walletLink** account type is invoked by the user.

Next, you’ll see how to invoke the plugin in your front-end application.

## Front-End Dai.js plugin implementation

To see the live implementation of these plugins, head to [oasis.app](https://oasis.app/).

Oasis.app is a good example of how Dai.js works in handling all the plugins that it supports. The [oasis.app/borrow](https://oasis.app/borrow) feature is stored in this [repo](https://github.com/makerdao/mcd-cdp-portal) that you can clone on your machine. In the cloned repo, you can see how the plugins are instantiated and used throughout the application.  

In the [/src/maker.js](https://github.com/makerdao/mcd-cdp-portal/blob/develop/src/maker.js) file you can see how the plugins are instantiated into the Dai.js SDK into a maker object that can be used everywhere across the application.

In [/src/utils/constants.js](https://github.com/makerdao/mcd-cdp-portal/blob/develop/src/utils/constants.js#L17) the different account types are defined that can be used in the application.

The [connectToProviderOfType](https://github.com/makerdao/mcd-cdp-portal/blob/develop/src/hooks/useMaker.js#L30) function will be used to invoke the **accountType** the user will choose in order to invoke the web3 engine provider.

Last thing, in [/src/components/AccountSelection.js](https://github.com/makerdao/mcd-cdp-portal/blob/develop/src/components/AccountSelection.js) we define the components that will be displayed for the user with the wallet options he can choose to interact with the application.

## Summary

This guide explained the process of creating a Dai.js wallet plugin and showed you the general pattern to integrate. As a rule of thumb, the more compatible your web3 provider is with the Dai.js SDK, the easier it will be to build the plugin. If it’s not compatible the guide showed you how to adapt the plugin to be able to communicate with the SDK. Lastly, it covered a live implementation of how to integrate your plugin with oasis.app.

## Additional Resources

If you want to dive deeper into the web3 providers, have a look at Metamask’s [web3-provider-engine repo](https://github.com/MetaMask/web3-provider-engine).

## Help

For any help, you can reach out at:

- [#dev](https://chat.makerdao.com/channel/dev) chat in [chat.makerdao.com](https://chat.makerdao.com/channel/dev).
