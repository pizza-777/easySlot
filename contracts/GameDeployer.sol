pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;

//deploy Game and bet
import "./Game.sol";
import "./Cashier.sol";

contract GameDeployer {
	TvmCell static gameCode;
	address static cashier;
	uint128 public balance;

	function deployAndPlay(address userWallet) public {
		require(msg.value > 1e8, 777, "msg.value must be greater than 1e8");
		tvm.accept();
		// 50 spins only allowed. Otherwise, the contract will be terminated: out of gas
		// if small (less than 1 ever) amount sent return money
		if (msg.value > 50e9 || msg.value < 1e9) {
			//return money to sender
			msg.sender.transfer(msg.value);
			return;
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

		//check balance of this contract.
		//if balance is less than 2 ever - ask to cashier for money
		replenish();
	}

	function replenish() public {	
		balance = address(this).balance - msg.value;

		if (balance < 2e9) {
			Cashier(cashier).replenishGameDeployer();			
		}		
	}
}
