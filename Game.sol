pragma ton-solidity >=0.47.0;
pragma AbiHeader expire;

contract Game {
	mapping(address => uint128) public balance;
	mapping(address => uint8[]) public randomNumbers;

	function play() public {
		uint8 spins = countSpins(balance[msg.sender]);
		uint8[] rand = getRandomNumbers(spins);
		randomNumbers[msg.sender] = rand;
		uint128 reward = calculateRewards(rand);
		sendReward(msg.sender, reward);
	}

	function calculateRewards(uint8[] rand)
		public
		pure
		returns (uint128 reward)
	{
		reward = 0;
		for (uint8 index = 0; index < rand.length; index++) {
			if (rand[index] > 5) {
				//todo make logic for different types of spins
				reward += 1950000000;
			}
		}
	}

	function deleteBalance(address addr) public {
		delete balance[addr];
	}

	function sendReward(address receiver, uint128 reward) public pure {
		receiver.transfer(reward, false, 3);
	}

	function getRandomNumbers(uint8 spins) public pure returns (uint8[] a) {
		rnd.shuffle(tx.timestamp);
		for (uint256 index = 0; index < spins; index++) a.push(rnd.next(9) + 1);
	}

	function countSpins(uint128 playerBalance) public pure returns (uint8) {
		return uint8(playerBalance / 1000000000);
	}

	receive() external {
		if (msg.value >= 1 ever) {
			tvm.accept();
			balance.add(msg.sender, 0);
			balance[msg.sender] = msg.value;
		}
		play();
	}

	function getUserRandomNumbers(address wallet)
		public
		view
		returns (uint8[])
	{
		return randomNumbers[wallet];
	}
}
