pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "https://raw.githubusercontent.com/tonlabs/debots/main/Debot.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/UserInfo/UserInfo.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Sdk/Sdk.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/AmountInput/AmountInput.sol";

interface IWallet {
	function sendTransaction(
		address dest,
		uint128 value,
		bool bounce,
		uint8 flags,
		TvmCell payload
	) external;
}

interface IGame {
	function getUserRandomNumbers(address wallet) external returns (uint8[]);
}

contract Slot is Debot {
	address wallet;

	uint256 b;

	address gameAddress =
		address.makeAddrStd(
			0,
			0x32574f88f1dfbf88122cbab5e757e43bb83dca05ee49b694233ed49826c08720
		);

	function start() public override {		
		Terminal.print(0, "Slot started");
		UserInfo.getAccount(tvm.functionId(setWallet));
	}

	function setWallet(address value) public {
		Terminal.print(0, format("Wallet set to {} ", value));
		wallet = value;
		depositProcedure();
	}

	function depositProcedure() public {
		Terminal.print(0, "Get balance");
		Sdk.getBalance(tvm.functionId(getUserWalletBalance), wallet);
	}

	function getUserWalletBalance(uint128 nanotokens) public {
		Terminal.print(
			0,
			format("User wallet balance: {} nanotokens", nanotokens)
		);
		if (nanotokens > 30000000000) nanotokens = 30000000000;
		AmountInput.get(
			tvm.functionId(deposit),
			"One spin 1 Ever",
			9,
			1e9,
			nanotokens
		);
	}

	function deposit(uint128 value) public {
		optional(uint256) pubkey;
		TvmCell empty;
		TvmCell message = tvm.buildExtMsg({
			dest: wallet,
			time: 0,
			expire: 0,
			call: {
				IWallet.sendTransaction,
				gameAddress,
				value,
				false,
				3,
				empty
			},
			sign: true,
			pubkey: pubkey,
			callbackId: tvm.functionId(depositCallback),
			onErrorId: tvm.functionId(depositErrorCallback)
		});
		tvm.sendrawmsg(message, 3);
	}

	function depositCallback() public {
		Terminal.print(0, "Success! {}");	
		IGame(gameAddress).getUserRandomNumbers{
			time: 0,
			expire: 0,
			sign: false,			
			callbackId: tvm.functionId(getUserRandomNumbersCallback),
			onErrorId: tvm.functionId(getUserRandomNumbersErrorCallback)
		}(wallet).extMsg;
	}

	function depositErrorCallback() public {
		Terminal.print(0, "Something went wrong. Please try again.{}");
	}

	function getUserRandomNumbersErrorCallback(uint32 sdkError, uint32 exitCode) public {
		Terminal.print(0, format("SdkError: {}, exitCode: {}", sdkError, exitCode));
	}

	function getUserRandomNumbersCallback(uint8[] randomNumbers) public {
		for (uint8 i = 0; i < randomNumbers.length; i++) {
			Terminal.print(0, format("Random numbers: {}", randomNumbers[i]));
		}
	}

	function getDebotInfo()
		public
		view
		override
		functionID(0xDEB)
		returns (
			string name,
			string version,
			string publisher,
			string key,
			string author,
			address support,
			string hello,
			string language,
			string dabi,
			bytes icon
		)
	{
		name = "Test DeBot";
		version = "0.0.1";
		publisher = "publisher name";
		key = "How to use";
		author = "Author name";
		support = address.makeAddrStd(
			0,
			0x000000000000000000000000000000000000000000000000000000000000
		);
		hello = "Hello, i am an test DeBot.";
		language = "en";
		dabi = m_debotAbi.get();
		icon = "";
	}

	function getRequiredInterfaces()
		public
		view
		override
		returns (uint256[] interfaces)
	{
		return [Terminal.ID];
	}
}
