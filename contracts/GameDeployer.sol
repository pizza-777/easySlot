pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

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
			value: msg.value,
			wid: address(this).wid,
			flag: 3
		}();

		gameAddress.transfer(2 ever, true, 3);
	}
}
