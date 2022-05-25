pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

interface ICashier {
	function pay(uint128 amount, address dest) external;
}

contract Game {
	uint8[] public randomNumbers;
	uint public b = 0;
	address static cashier;
	address static userWallet;

	function play() public {
		tvm.accept();
		b = 15;
		uint8 spins = countSpins(msg.value);
		randomNumbers = getRandomNumbers(spins);
		uint128 reward = calculateRewards(randomNumbers);
		if(reward > 0) sendReward(userWallet, reward);
	}

	function calculateRewards(uint8[] rand)
		public
		pure
		returns (uint128 reward)
	{
		reward = 0;
		for (uint8 index = 0; index < rand.length; index++) {
			if (rand[index] > 0) {
				//todo make logic for different types of spins
				reward += 1950000000;
			}
		}
	}

	function sendReward(address receiver, uint128 reward) public  {
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

	function getRandomNumbers(uint8 spins) public pure returns (uint8[] a) {
		rnd.shuffle(tx.timestamp);
		for (uint256 index = 0; index < spins; index++) a.push(rnd.next(9) + 1);
	}

	function countSpins(uint128 playerBalance) public pure returns (uint8) {
		return uint8(playerBalance / 1000000000);
	}

	function getCode() public pure returns(TvmCell){
		return tvm.code();
	}

	// function setCashier(address _cashier) public {
	// 	address empty;
	// 	require(cashier == empty, 101, "Cashier already set");
	// 	tvm.accept();
	// 	cashier = _cashier;
	// }

	receive() external {
		tvm.accept();
		b++;
		if (msg.value >= 1 ever) {
			tvm.accept();
			b = b + 2;
		}
		play();
	}
}

