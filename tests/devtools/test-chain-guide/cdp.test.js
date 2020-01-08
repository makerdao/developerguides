const start = require('./cdp');

// Before running the test, make sure to run the testchain instance
// from the test-chain-guide

test('check to see if 20 dai is generated', async () => {
    expect(await start()).toMatch("20.00 MDAI");
});
