const Maker = require('@makerdao/dai');
const McdPlugin = require('@makerdao/dai-plugin-mcd').default;
const ETH = require('@makerdao/dai-plugin-mcd').ETH;
const MDAI = require('@makerdao/dai-plugin-mcd').MDAI;

async function start() {
	try {
		const maker = await Maker.create('test', {
			plugins: [
				[McdPlugin, {}]
			]
		});
		await maker.authenticate();

		const balance = await maker
			.service('token')
			.getToken('ETH')
			.balance();
		console.log('Account: ', maker.currentAddress());
		console.log('Balance', balance.toString());

		const cdp = await maker
			.service('mcd:cdpManager')
			.openLockAndDraw('ETH-A', ETH(1), MDAI(20));

		console.log('Opened CDP #'+cdp.id);
		console.log('Collateral amount:'+cdp.collateralAmount.toString());
		console.log('Debt Value:'+cdp.debtValue.toString());

		return(cdp.debtValue.toString());
	} catch (error) {
		console.log('error', error);
	}
}
module.exports = start;
