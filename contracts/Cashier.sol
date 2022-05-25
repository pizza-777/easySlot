pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./Game.sol";

contract Cashier {
	TvmCell gameCode;
	uint128 public _amount;
	address public _userWallet;
	address public _sender;
	address public _expected;
	uint256 public _msgPubkey;
	uint256 public _tvmPubkey;
	bool public got = false;

	function pay(uint128 amount, address userWallet) public {
		// tvm.accept();
		// _tvmPubkey = tvm.pubkey();
		// _msgPubkey = msg.pubkey();
		// _expected = _getExpectedAddress(userWallet);
		// _sender = msg.sender;
		// _amount = amount;
		// _userWallet = userWallet;
		require(msg.value >= 1e8, 1001, "Insufficient funds");
		tvm.accept();
		require(
			msg.sender == _getExpectedAddress(userWallet),
			101,
			"invalid sender"
		);
		got = true;
		userWallet.transfer(amount, true, 3);
	}

	function _getExpectedAddress(address uWallet) public returns (address) {
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
		require(gameCode == empty, 101, "game code already set");
		tvm.accept();
		gameCode = _gameCode;
	}
}
