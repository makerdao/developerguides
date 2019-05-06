const Maker = require('@makerdao/dai');

async function start() {
	try {
		const maker = await Maker.create('test');
		await maker.authenticate();

		// Get account and balance
		const balance = await maker.getToken('ETH').balanceOf(maker.currentAddress());
		console.log('Account: ', maker.currentAddress());
		console.log('Balance', balance.toString());

		// Open CDP, lock ETH and Draw DAI
		const cdp = await maker.openCdp();
		console.log('Opened CDP with ID: ', cdp.id)

		await cdp.lockEth(0.1)
		console.log('Locked ETH')
		await cdp.drawDai(5)
		console.log('Draw DAI');

		const debt = await cdp.getDebtValue();
		console.log(debt.toString());
		return debt.toString()

	} catch (error) {
		console.log('error', error)
	}
}
module.exports = start