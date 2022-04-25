pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "https://raw.githubusercontent.com/tonlabs/debots/main/Debot.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/UserInfo/UserInfo.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Sdk/Sdk.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/AmountInput/AmountInput.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/SigningBoxInput/SigningBoxInput.sol";

interface IWallet {
	function sendTransaction(
		address dest,
		uint128 value,
		bool bounce,
		uint8 allBalance,
		TvmCell payload
	) external returns (uint64 transId);
}


contract Slot is Debot {
	address wallet;

	address static gameAddress;

	function start() public override {
		UserInfo.getAccount(tvm.functionId(setWallet));
	}

	function setWallet(address value) public {
		wallet = value;
	}

	function depositProcedure() public {
		Sdk.getBalance(tvm.functionId(getUserWalletBalance), wallet);
	}

	function getUserWalletBalance(uint128 nanotokens) public {
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
		optional(uint256) pubkey = 0;
		TvmCell empty;
		IWallet(wallet).sendTransaction{
			sign: true,
			pubkey: pubkey,
			time: uint64(now),
			expire: 0,
			callbackId: tvm.functionId(onSuccess),
			onErrorId: tvm.functionId(onError)
		}(gameAddress, value, true, 3, empty).extMsg; // Just repeat if something went wrong
	}

	function onSuccess(uint64 transId) public {
		delete transId;
		Terminal.print(0, format("Success!"));
		start();
	}

	function onError(uint32 exitCode) public {
		Terminal.print(
			0,
			format("Something went wrong. Please try again.{}", exitCode)
		);
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
