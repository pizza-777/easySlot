pragma ton-solidity >=0.59.4;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "https://raw.githubusercontent.com/tonlabs/debots/main/Debot.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/UserInfo/UserInfo.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Sdk/Sdk.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Menu/Menu.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/AmountInput/AmountInput.sol";
import "./GameDeployer.sol";

interface IGame {
	function randomNumbers() external returns (mapping(uint8 => uint8[]));
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
	address public userWallet;
	address public gameAddress;
	TvmCell public static gameCode;
	address public static gameDeployer;
	address public static cashier;
	uint128 public amountInput;

	bytes m_icon;

	function setIcon(bytes icon) public {
		require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		m_icon = icon;
	}

	function _menu(uint32 handleMenu1) private pure inline { 
		Menu.select(
			"SlotDebot",
			"description for menu",
			[MenuItem("PLAY", "", handleMenu1)]
		);
	}

	function start() public override {
		_menu(tvm.functionId(getWallet));
	}

	function getBalance() public view {
		Sdk.getBalance(tvm.functionId(getUserWalletBalance), userWallet);
	}

	function getUserWalletBalance(uint128 nanotokens) public pure {
		if (nanotokens < 1e9) {
			Terminal.print(
				0,
				"You have low balance on your Surf wallet. Please deposit more."
			);
		} else {
			if (nanotokens > 50e9) nanotokens = 50e9; // max 50e9
			AmountInput.get(
				tvm.functionId(setAmount),
				"One spin 1 Ever",
				9,
				1e9,
				nanotokens
			);
		}
	}

	function setAmount(uint128 value) public {
		amountInput = uint128(value / 1e9) * 1e9; //floor
		setGameAddress();
	}

	function getWallet() public pure {
		UserInfo.getAccount(tvm.functionId(setWallet));
	}

	function setWallet(address value) public {
		userWallet = value;
		getBalance();
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
		optional(uint256) pubkey;
		if (acc_type == -1) {
			//send transaction to gameDeployer
			TvmCell payload = tvm.encodeBody(
				GameDeployer.deployAndPlay,
				userWallet
			);
			TvmCell message = tvm.buildExtMsg({
				dest: userWallet,
				time: 0,
				expire: 0,
				call: {
					IWallet.sendTransaction,
					gameDeployer,
					amountInput,
					false,
					3,
					payload
				},
				sign: true,
				pubkey: pubkey,
				callbackId: tvm.functionId(depositCallback),
				onErrorId: tvm.functionId(errorCallback)
			});
			tvm.sendrawmsg(message, 3);
		} else {
			//send message to Game.sol
			TvmCell none;
			TvmCell message = tvm.buildExtMsg({
				dest: userWallet,
				time: 0,
				expire: 0,
				call: {
					IWallet.sendTransaction,
					gameAddress,
					amountInput,
					false,
					3,
					none
				},
				sign: true,
				pubkey: pubkey,
				callbackId: tvm.functionId(depositCallback),
				onErrorId: tvm.functionId(errorCallback)
			});
			tvm.sendrawmsg(message, 3);
		}
	}

	function depositCallback() public view {
		IGame(gameAddress).randomNumbers{
			time: 0,
			expire: 0,
			sign: false,
			callbackId: tvm.functionId(getUserRandomNumbersCallback),
			onErrorId: tvm.functionId(errorCallback)
		}().extMsg;
	}

	function errorCallback(uint32 sdkError, uint32 exitCode) public pure {
		Terminal.print(
			0,
			format("sdkError: {}, exitCode: {}", sdkError, exitCode)
		);
	}

	function getUserRandomNumbersCallback(
		mapping(uint8 => uint8[]) randomNumbers
	) public {
		string[] slotEmoji = ["💎", "🍌", "🍎", "🍊", "🍉", "🍋"];
		for ((, uint8[] value): randomNumbers) {
			string profit = "";
			if (value[3] > 0) {
				profit = format("+{}", value[3]);
			}
			Terminal.print(
				0,
				format(
					"{}  {}  {}  {}",
					slotEmoji[uint8(value[0]) - 1],
					slotEmoji[uint8(value[1]) - 1],
					slotEmoji[uint8(value[2]) - 1],
					profit
				)
			);
		}
		start();
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
		name = "Slot DeBot";
		version = "0.0.1";
		publisher = "pizzza777";
		key = "Game";
		author = "pizzza777";
		support = address.makeAddrStd(
			0,
			0x7c748782a188ae06cd79132ce2f3622dd0b7000708cc9efe504f6d3b72a32088
		);
		hello = "Hello, I'm Slot DeBot";
		language = "en";
		dabi = m_debotAbi.get();
		icon = m_icon;
	}

	function getRequiredInterfaces()
		public
		view
		override
		returns (uint256[] interfaces)
	{
		return [Terminal.ID, UserInfo.ID, Sdk.ID, Menu.ID, AmountInput.ID];
	}
}
