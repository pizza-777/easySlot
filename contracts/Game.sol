pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
// pragma AbiHeader time;
// pragma AbiHeader pubkey;

interface ICashier {
	function pay(uint128 amount, address dest) external;
}

contract Game {
	mapping(uint8 => uint8[]) public randomNumbers;
	uint256 public b = 0;
	address static cashier;
	address static userWallet;
	uint128 public msgv;
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
			(a1 == 1 || a2 == 1) || (a2 == 1 || a3 == 1) || (a3 == 1 || a1 == 1)
		) {
			return 4;
		}
		//any one gem
		if (a1 == 1 || a2 == 1 || a3 == 1) {
			return 1;
		}
		return 0;
	}

	function play() public {
		
		b = 15;
		uint8 spins = countSpins(msg.value);b = 52;
		randomNumbers = getRandomNumbers(spins);b = 53;
		uint128 reward = calculateRewards(randomNumbers);b = 54;
		if (reward > 0) sendReward(userWallet, reward);b = 55;
	}

	function calculateRewards(mapping(uint8 => uint8[]) rand)
		public
		pure
		returns (uint128 reward)
	{
		reward = 0;
		for ((, uint8[] value) : rand) { 
			reward += winningCombinations(
				value[0],
				value[1],
				value[2]
			);
		}
	}

	function sendReward(address receiver, uint128 reward) public {
		b = 37;
		if (reward < (address(this).balance - 1e9)) {
			//remain 1 ever
			b = 40;
			receiver.transfer(reward);
		} else {
			b = 43;
			ICashier(cashier).pay{value: 1e8, flag: 3}(reward, receiver);
		}
	}

	function getRandomNumbers(uint8 spins) public pure returns (mapping(uint8 => uint8[]) a) {
		rnd.shuffle(tx.timestamp);
		for (uint8 index = 0; index < spins; index++)
			a.add(index, [rnd.next(6) + 1, rnd.next(6) + 1, rnd.next(6) + 1]);
	}

	function countSpins(uint128 playerBalance) public pure returns (uint8) {
		return uint8(playerBalance / 1000000000);
	}

	function getCode() public pure returns (TvmCell) {
		return tvm.code();
	}

	receive() external {
		if (msg.value >= 1e9) {
			tvm.accept();
			b = b + 2;
		}
		play();
	}

	function showRandomNumbers() public view returns (mapping (uint8=>uint8[])){	
		//randomNumbers.add(1, [1,2,3]);			
		return randomNumbers;
	}
}
