# Example of Wyre Real-Money Transfers

- [Example of Wyre Real-Money Transfers](#example-of-wyre-real-money-transfers)
  - [Recipe for transferring $100 from a Wyre Business Account to a US Personal Bank Account](#recipe-for-transferring-100-from-a-wyre-business-account-to-a-us-personal-bank-account)

This document provides an example of a process for setting up real-money cross-border transfers, where the Dai stablecoin is used for the cross-border settlement.

We will explain the process of setting up real-money cross-border transfers using the Wyre API.
In order to get familiar with and test Wyre’s services, you can try out their [sandbox service.](https://www.testwyre.com)

In order to to get started you connect with [MetaMask](https://metamask.io/) or a hardware wallet to create an account. The sandbox functionality will not be elaborated further, as this document will explain how to set up real money transfers.

## Recipe for transferring $100 from a Wyre Business Account to a US Personal Bank Account

**1. Create account on Wyre - and perform KYC:**

- First, you must create a [Wyre business account](https://dash.sendwyre.com/sign-up).
- The signup process will guide you through a [KYC check](https://support.sendwyre.com/getting-started/go-from-fiat-to-crypto-in-3-steps), that requires you to submit business credentials in order to get verified.
- The verification process took approximately 1 day.
- Once you are verified, you are ready to add funds to the account.

**2. Add funds to your account:**

- In order to add funds, you must link either a bank account or a payment card to your Wyre account. This is done through My Account > Payment Methods.
- We added funds to a USD account and to a EUR account using the added payment method.

**3. Create an API key so you can use Wyre’s API:**

In order to use the Wyre API, you must create an API key.

- This is done by accessing Your Account > API Keys > Add API Key
- We restricted our API key, so it can be used only from our office IP address.
- Once the API key is generated, we are ready to make transfers using the Wyre API.

**4. Send money**
Now that you have setup an account (1), added funds (2), and generated an API key (3), we are finally ready to send some money from the Wyre account to a recipient bank account.

**4.a First case (USD->USD)**
The first case will transfer 100 USD from the Wyre account, to a recipient in USA, who will receive the money in USD (USD->USD transfer).

- First, we assume that you have sufficient USD funds in your Wyre account.
- You must authenticate with the Wyre API key. We used the following code to authenticate.

```javascript
const WyreClient = require('@wyre/api').WyreClient
const wyre = new WyreClient({
  format: "json_numberstring",
  apiKey: 'YOUR_WYRE_API_KEY',
  secretKey: "YOUR_WYRE_SECRET_KEY",
  baseUrl: "https://api.sendwyre.com/v3"
})
```

Now you are able to submit an API request to make the transfer. To do so, you must specify the following parameters regarding the payment and the beneficiary.

- `paymentMethodType`
- `paymentType`
- `currency`
- `country`
- `beneficiaryType`
- `firstNameOnAccount`
- `lastNameOnAccount`
- `beneficiaryPhoneNumber`
- `accountNumber`
- `routingNumber`
- `accountType`
- `chargeablePM`

The most important parameters are the info you need about the recipient, which is their name, country of bank account, phone number, account number, routing number and account type.
You must also specify parameters regarding the transfer itself:

- `sourceCurrency`
- `destCurrency`
- `sourceAmount`/`destAmount`
- `autoConfirm`

Here you specify the currency `sourceCurrency` and the amount `sourceAmount` you want to transfer from your account. You can also choose to use the parameter `destAmount` to specify the exact receivable funds in the destination currency `destCurrency` if you are doing an exchange transfer eg. from EUR to USD. This way with `destAmount` you can specify that the user will receive exactly 100 USD, if you are using a different source currency such as EUR as the system will calculate the amount of EUR that needs to be sent in order to be exchanged into exactly a 100 USD.

- In both our cases, we used the sourceAmount parameter, as it is redundant whichever you use for the USD->USD case, and for the second case (EUR->USD) we were not too worried about the exact receivable amount in the destination currency.
- A more detailed explanation of all the parameters can [be found here](https://www.sendwyre.com/docs/#usa).
- In our case, we used the following code to transfer 100 USD from our Wyre account to an individual, (referred to as John Doe), in the US, receiving the money in USD. The filled out parameters are highlighted in yellow. Phone number and account number have been changed to fictitious values.

```javascript
async function transferUsdtoClientBank() {
try{
  let transfer = await wyre.post('/transfers', {
    dest:{
      paymentMethodType: "INTERNATIONAL_TRANSFER",
      paymentType: 'LOCAL_BANK_WIRE',
      currency: 'USD',
      country: "US",
      beneficiaryType: 'INDIVIDUAL',
      firstNameOnAccount: 'John',
      lastNameOnAccount: 'Doe',
      beneficiaryPhoneNumber: '13475550199',
      accountNumber: '99999999',
      routingNumber: '21000089',
      accountType: 'CHECKING',
      chargeablePM: true
    },
    sourceCurrency: 'USD',
    destCurrency: 'USD',
    sourceAmount: 100,
    autoConfirm: true
    })
  console.log('usd to client status:', transfer)
}
  catch(err) {
  console.log('usd to client', err);
 }
}
```

**4.b Second case (EUR->USD):**

- In order to send EUR from the Wyre account, to be received as USD in the recipient account in the US, you follow the steps above, and just change the sourceCurrency: 'USD',  value to 'EUR' and the Wyre system uses its own exchange system to finalize the transfer in USD to the recipient’s account, as specified by the destCurrency: 'USD'.

**4.c Cost of transfers:**

- Wyre states that the retail fee is 0.75 % for currency exchange transfers and cryptocurrency exchange transfers, and 0.20 % for same currency transfers. There is always at least a flat fee of 1 USD for transfers to USD.
- Consequently, for transfers around a 100 USD the minimum flat fee is invoked, as Wyre chooses which ever is greater of either the specified percentage or the fixed fee. For our 100 USD-USD transfers the fees was a flat 1 USD = 1 %, while the EUR-USD transfer had a fee of 0.88 EUR = 1 USD. Both transfers thus cost 1 USD.

For a full explanation of fees check out [Wyre’s fee overview.](https://support.sendwyre.com/fees-and-rates/wyre-fees-overview)

**4.d Time frames on transfers:**

- Our test results on time spent from creation to completion of a Wyre transfer to a USD bank account:

  ```bash
  transfer initiated at: UTC 2018-12-03 T 09:24:56
  transfer completed at: UTC 2018-12-04 T 15:53:39
  ```
  
- In average, from initiating and completing the Wyre to USD bank account transfer we experienced a period of ~30 hours for our two transfers.
- Wyre states that: “Bank cut-off time is 12PM PST. If we receive the payment instruction on the day before 12PM, the payment will be credited to beneficiary the next business day. If we receive the payment instruction after 12PM, it will be credited to beneficiary next business day +1.”

**5. A note about transaction fees:**

- Wyre states that tiered pricing is available, and that the pricing is reliant on the volume on the Wyre account rather than the size of transactions. Therefore, the greater the volume on the account, the more the fixed fee on transactions will decrease.
- The retail fee is 0.75 % for currency exchange transfers and cryptocurrency exchange transfers and 0.20 % for same currency transfers, however in the case of an account with large volumes, the fixed fees will be lower.  
- For exchange transfers to USD there is a minimum fee of 1.00 USD.
- Wyre guarantees that the supply/demand will not impact the agreed fee structure.
