const start = require('./cdp');

// Before running the test, make sure to run the testchain instance
// from the test-chain-guide

test('check to see if 5 dai is generated', async () => {
    expect(await start()).toMatch("5.00 DAI");
})