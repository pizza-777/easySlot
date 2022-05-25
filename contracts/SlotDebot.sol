pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "https://raw.githubusercontent.com/tonlabs/debots/main/Debot.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/UserInfo/UserInfo.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Sdk/Sdk.sol";
import "./Game.sol";

interface IGameDeployer {
	function deployAndPlay(address userWallet) external;
}

interface IWallet {
	function sendTransaction(
		address dest,
		uint128 value,
		bool bounce,
		uint8 flags,
		TvmCell payload
	) external;
}

contract SlotDebot is Debot {
	uint256 public userPubkey;
	address public userWallet;
	address public gameAddress;
	TvmCell static public gameCode;	
	address static public gameDeployer;
	address static public cashier;

	function start() public override {
		UserInfo.getPublicKey(tvm.functionId(setPubkey));
	}

	function setPubkey(uint256 value) public {
		userPubkey = value;
		UserInfo.getAccount(tvm.functionId(setWallet));
	}

	function setWallet(address value) public {
		userWallet = value;
		setGameAddress();
	}

	function setGameAddress() public {
		gameAddress = address(
			tvm.hash(
				tvm.buildStateInit({
					code: gameCode,			
					varInit: {cashier: cashier, userWallet: userWallet},
					contr: Game
				})
			)
		);
		Sdk.getAccountType(tvm.functionId(setGameStatus), gameAddress);
	}

	function setGameStatus(int8 acc_type) public view {
		//debug information - comment it
		Terminal.print(0, format("userPubkey: {}", userPubkey));
		Terminal.print(0, format("Wallet set to {} ", userWallet));
		Terminal.print(0, format("GameDeployer set to {} ", gameDeployer));
		Terminal.print(0, format("Game address: {}", gameAddress));
		Terminal.print(0, format("Game status {}", acc_type));
		Terminal.print(0, format("Cashier set to {}", cashier));
		// end of debug information

		if (acc_type == -1) {
			Terminal.print(0, "Need to deploy");
			TvmCell payload = tvm.encodeBody(
				IGameDeployer.deployAndPlay,
				userWallet
			);
			optional(uint256) pubkey;
			TvmCell message = tvm.buildExtMsg({
				dest: userWallet,
				time: 0,
				expire: 0,
				call: {
					IWallet.sendTransaction,
					gameDeployer,
					1000000000,
					false,
					3,
					payload
				},
				sign: true,
				pubkey: pubkey,
				callbackId: tvm.functionId(depositCallback),
				onErrorId: tvm.functionId(depositErrorCallback)
			});
			tvm.sendrawmsg(message, 3);
		}
		// Terminal.print(0, format("Game status {}", acc_type));
	}

	function depositCallback() public pure {
		Terminal.print(0, "Success! {}");
	}

	function depositErrorCallback(uint32 sdkError, uint32 exitCode)
		public
		pure
	{
		Terminal.print(
			0,
			format("sdkError: {}, exitCode: {}", sdkError, exitCode)
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
		return [Terminal.ID, UserInfo.ID, Sdk.ID];
	}
}
