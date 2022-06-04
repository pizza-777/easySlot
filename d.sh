# deployment in network with everdev
# signer2 - is your surf signer in everdev.

# set params
pubkey=0xb71ca8aff09fd4b06d90143b3e87162d7cf099ba74e7f9380e06bbca3d3b4f1f

network=main

# money ...
cashierValue=3e9
gameValue=3e8
slotDebotValue=3e8
gameDeployerValue=3e8

if [ $network == se ]; then
    everdev se reset
fi

everdev network default $network

rm ./artifacts/Game.abi.json
rm ./artifacts/SlotDebot.abi.json
rm ./artifacts/Cashier.abi.json
rm ./artifacts/GameDeployer.abi.json

rm ./artifacts/Game.tvc
rm ./artifacts/SlotDebot.tvc
rm ./artifacts/Cashier.tvc
rm ./artifacts/GameDeployer.tvc

if [ $network == se ]; then
    everdev c d ./artifacts/multisig.abi.json -s signer2 -v 1000e9 -i "owners:[$pubkey],reqConfirms:1"
fi

everdev sol compile ./contracts/Cashier.sol -o ./artifacts
Cashier=$(everdev c d ./artifacts/Cashier.abi.json -v $cashierValue | grep address | cut -d':' -f3 | xargs)

everdev sol compile ./contracts/Game.sol -o ./artifacts   
                            
game=$(everdev c d ./artifacts/Game.abi.json -v $gameValue -d cashier:$Cashier,userWallet:$Cashier,shardSalt:1 | grep address | cut -d':' -f3 | xargs)

gameCode=$(everdev c l ./artifacts/Game.abi.json getCode -d cashier:$Cashier,userWallet:$Cashier,shardSalt:1 | grep value0 | cut -d':' -f2 | cut -d'"' -f2 | xargs)

everdev sol compile ./contracts/GameDeployer.sol -o ./artifacts

gameDeployer=$(everdev c d ./artifacts/GameDeployer.abi.json -v $gameDeployerValue -d gameCode:$gameCode,cashier:$Cashier | grep address | cut -d':' -f3 | xargs)

# set "static" vars
 everdev c r ./artifacts/Cashier.abi.json setGameCode -i _gameCode:$gameCode -a $Cashier
 everdev c r ./artifacts/Cashier.abi.json setGameDeployer -i _gameDeployer:$gameDeployer -a $Cashier

 everdev sol compile ./contracts/SlotDebot.sol -o ./artifacts
 SlotDebot=$(everdev c d ./artifacts/SlotDebot.abi.json -v $slotDebotValue -d gameCode:$gameCode,gameDeployer:$gameDeployer,cashier:$Cashier | grep address | cut -d':' -f3 | xargs)
 everdev c r ./artifacts/SlotDebot.abi.json setABI --input "dabi:'$(cat ./artifacts/SlotDebot.abi.json | xxd -ps -c 20000)'" -a $SlotDebot
 ICON_BYTES=$(base64 -w 0 slotDebot.png)
 ICON=$(echo -n "data:image/png;base64,$ICON_BYTES" | xxd -ps -c 20000)
 everdev c r ./artifacts/SlotDebot.abi.json setIcon --input "icon:'$ICON'" -a $SlotDebot

 echo "GameDeployer: 0:$gameDeployer" &> ./$network.log
 echo "Game: 0:$game" >> ./$network.log
 echo "Cashier: 0:$Cashier" >> ./$network.log
 echo "SlotDebot: 0:$SlotDebot" >> ./$network.log

 cat ./$network.log