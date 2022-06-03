pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;

interface ICashier {
	function pay(
		uint128 amount,
		address userWallet,
		uint256 shardSalt
	) external;
}

contract Game {
	mapping(uint8 => uint8[]) public randomNumbers;
	address public static cashier;
	address public static userWallet;
	uint256 public static shardSalt;

	//uint static salt;//for deployment
	// for tests
	// address cashier =
	// 	address(
	// 		0x66724c81ea720337600edc7fc19046a4d2b42dbe335dafd5b39cd96781ad95b7
	// 	);
	// address userWallet =
	// 	address(
	// 		0xd8eb71bef7353a98458be0d3b0a0fd37e09cad6b2b7a98f45ae082b7fad51f4d
	// 	);

	//1-gem
	//2-banana
	//3-apple
	//4-orange
	//5-watermelon
	//6-lemon
	uint8[] slotNums = [1, 2, 3, 4, 5, 6];

	function winningCombinations(
		uint8 a1,
		uint8 a2,
		uint8 a3
	) public pure returns (uint8) {
		//3 gems
		if (a1 == 1 && a2 == 1 && a3 == 1) {
			return 30;
		}
		//any 3 same
		if (a1 == a2 && a2 == a3) {
			return 10;
		}
		//any 2 gems
		if (
			(a1 == 1 && a2 == 1) || (a2 == 1 && a3 == 1) || (a3 == 1 && a1 == 1)
		) {
			return 4;
		}
		//any one gem
		if (a1 == 1 || a2 == 1 || a3 == 1) {
			return 1;
		}
		return 0;
	}

	function play(uint128 _msgValue) public returns (string) {
		uint8 spins = countSpins(_msgValue);
		(uint128 reward, ) = getRandomNumbersAndRewards(spins);
		if (reward >= 1e9) {
			string sender = sendReward(userWallet, reward);
			return sender;
		} else {
			return "Reward doesn't exceed 1e9";
		}
	}

	function sendReward(address receiver, uint128 reward)
		public
		view
		returns (string sender)
	{
		//remain 1 ever
		if (reward < (address(this).balance - 1e9)) {
			receiver.transfer(reward, true, 3);
			// if this Game have a lot of money, then send to cashier
			if(address(this).balance - reward - 1e9 > 50e9) {
				cashier.transfer(20e9, true, 3);
			}
			return "Game";
		} else {
			ICashier(cashier).pay{value: 1 ever}(reward, receiver, shardSalt);
			return "Cashier";
		}
	}

	function getRandomNumbersAndRewards(uint8 spins)
		public
		returns (uint128 rewards, mapping(uint8 => uint8[]) rn)
	{
		//tvm.accept(); //for testing only comment this line
		for (uint8 index = 0; index < spins; index++)
			rn.add(index, [rnd.next(6) + 1, rnd.next(6) + 1, rnd.next(6) + 1]);

		for ((uint8 k, uint8[] value): rn) {
			uint8 reward = winningCombinations(value[0], value[1], value[2]);
			rn[k].push(reward);
			rewards += reward; //in evers
		}
		randomNumbers = rn;
		rewards = rewards * 1e9; //in nano evers
	}

	function countSpins(uint128 playerBalance) public pure returns (uint8) {
		return uint8(playerBalance / 1e9);
	}

	function getCode() public pure returns (TvmCell) {
		return tvm.code();
	}

	receive() external {
		require(msg.value > 1e8, 777, "msg.value must be greater than 1e8");
		tvm.accept();
		// 50 spins only allowed. Otherwise, the contract will be terminated: out of gas
		// if small (less than 1 ever) amount sent return money
		if (msg.value > 50e9 || msg.value < 1e9) {
			//return money to sender
			msg.sender.transfer(msg.value);
		} else {
			//play game
			play(msg.value);
		}
	}

	function withdraw(uint128 amount) public view {
		require(
			msg.pubkey() == tvm.pubkey(),
			1004,
			"only boss can run this function"
		);
		tvm.accept();
		cashier.transfer(amount);
	}
}
