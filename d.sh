#game code
everdev se reset

rm ./artifacts/Game.abi.json
rm ./artifacts/SlotDebot.abi.json
rm ./artifacts/Cashier.abi.json
rm ./artifacts/GameDeployer.abi.json

rm ./artifacts/Game.tvc
rm ./artifacts/SlotDebot.tvc
rm ./artifacts/Cashier.tvc
rm ./artifacts/GameDeployer.tvc

everdev c d ./artifacts/multisig.abi.json --signer surf1 --value 1000000000000 -i "owners:[0x86a6e1bab34b4907bd39ce51090f9b4db2f0adb665d38862e00009fa2e0b2baf],reqConfirms:1"

everdev sol compile ./contracts/Cashier.sol -o ./artifacts
Cashier=$(everdev c d ./artifacts/Cashier.abi.json -v 100000000000 | grep address | cut -d':' -f3 | xargs)

everdev sol compile ./contracts/Game.sol -o ./artifacts   
echo 20                                   
game=$(everdev c d ./artifacts/Game.abi.json -v 1000000000000 -d cashier:$Cashier,userWallet:$Cashier | grep address | cut -d':' -f3 | xargs)
echo 22
gameCode=$(everdev c l ./artifacts/Game.abi.json getCode -d cashier:$Cashier,userWallet:$Cashier | grep value0 | cut -d':' -f2 | cut -d'"' -f2 | xargs)
echo 24
everdev sol compile ./contracts/GameDeployer.sol -o ./artifacts
echo 26
gameDeployer=$(everdev c d ./artifacts/GameDeployer.abi.json -v 100000000000 -d gameCode:$gameCode,cashier:$Cashier | grep address | cut -d':' -f3 | xargs)
echo 28
# set "static" vars
 everdev c r ./artifacts/Cashier.abi.json setGameCode -i _gameCode:$gameCode -a $Cashier
#  everdev c r ./artifacts/Game.abi.json setCashier -i _cashier:$Cashier -d 

 everdev sol compile ./contracts/SlotDebot.sol -o ./artifacts
 SlotDebot=$(everdev contract deploy ./artifacts/SlotDebot.abi.json --value 10000000000 -d gameCode:$gameCode,gameDeployer:$gameDeployer,cashier:$Cashier | grep address | cut -d':' -f3 | xargs)
 everdev contract run ./artifacts/SlotDebot.abi.json setABI --input "dabi:'$(cat ./artifacts/SlotDebot.abi.json | xxd -ps -c 20000)'" -a $SlotDebot

 echo "GameDeployer: 0:$gameDeployer"
 echo "Game: 0:$game"
 echo "Cashier: 0:$Cashier"
 echo "SlotDebot: 0:$SlotDebot"