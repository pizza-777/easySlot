pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./Game.sol";

contract Cashier {
	TvmCell gameCode;
	address public gameDeployer;

	uint static salt;//for deployment

	function pay(uint128 amount, address userWallet) public view {
		require(msg.value >= 1e8, 1001, "Insufficient funds");
		tvm.accept();
		require(
			msg.sender == _getExpectedAddress(userWallet),
			101,
			"invalid sender"
		);

		userWallet.transfer(amount, true, 3);
	}

	function _getExpectedAddress(address uWallet)
		public
		view
		returns (address)
	{
		return
			address(
				tvm.hash(
					tvm.buildStateInit({
						code: gameCode,
						varInit: {cashier: address(this), userWallet: uWallet},
						contr: Game
					})
				)
			);
	}

	function setGameCode(TvmCell _gameCode) public {
		TvmCell empty;
		require(gameCode == empty, 1001, "game code already set");
		tvm.accept();
		gameCode = _gameCode;
	}

	function setGameDeployer(address _gameDeployer) public {
		address empty;
		require(gameDeployer == empty, 1002, "game deployer already set");
		tvm.accept();
		gameDeployer = _gameDeployer;
	}

	function replenishGameDeployer() public view {
		require(msg.sender == gameDeployer, 1003, "invalid sender");
		tvm.accept();
		gameDeployer.transfer(5 ever, true, 3);
	}

	function withdraw(address boss, uint128 amount) public view {
		require(
			msg.pubkey() == tvm.pubkey(),
			1004,
			"only boss can run this function"
		);
		tvm.accept();
		boss.transfer(amount);
	}
}
