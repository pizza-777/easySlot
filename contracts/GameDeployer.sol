pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;

 
//deploy Game and bet
import "./Game.sol";

contract GameDeployer {
	TvmCell static gameCode;
	address static cashier;

	function deployAndPlay(address userWallet) public view { 
		if (msg.value >= 1 ever) {
			tvm.accept();
		}
		TvmCell stateInit = tvm.buildStateInit({
			code: gameCode,
			varInit: {cashier: cashier, userWallet: userWallet},
			contr: Game
		});

		address gameAddress = new Game{
			stateInit: stateInit,
			value: 2e8,
			wid: address(this).wid,
			flag: 3
		}();

		gameAddress.transfer(msg.value, false, 3);
	}
}
