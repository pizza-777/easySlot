# deployment in dev network with everdev

# get address
# everdev c info ./artifacts/GiverV2.abi.json

# topup giver from bot @everdev_giver_bot
# 60 rubins minimum
# deploy giver
# everdev c d ./artifacts/GiverV2.abi.json --network dev

#setup giver
#everdev network giver dev 0:giverAddress

rm ./artifacts/Game.abi.json
rm ./artifacts/SlotDebot.abi.json
rm ./artifacts/Cashier.abi.json
rm ./artifacts/GameDeployer.abi.json

rm ./artifacts/Game.tvc
rm ./artifacts/SlotDebot.tvc
rm ./artifacts/Cashier.tvc
rm ./artifacts/GameDeployer.tvc

everdev network default dev

salt=$RANDOM

everdev sol compile ./contracts/Cashier.sol -o ./artifacts
Cashier=$(everdev c d ./artifacts/Cashier.abi.json -v 1e9 | grep address | cut -d':' -f3 | xargs)

everdev sol compile ./contracts/Game.sol -o ./artifacts   
                            
game=$(everdev c d ./artifacts/Game.abi.json -v 1e8 -d cashier:$Cashier,userWallet:$Cashier,shardSalt:1 | grep address | cut -d':' -f3 | xargs)

gameCode=$(everdev c l ./artifacts/Game.abi.json getCode -d cashier:$Cashier,userWallet:$Cashier,shardSalt:1 | grep value0 | cut -d':' -f2 | cut -d'"' -f2 | xargs)

everdev sol compile ./contracts/GameDeployer.sol -o ./artifacts

gameDeployer=$(everdev c d ./artifacts/GameDeployer.abi.json -v 1e9 -d gameCode:$gameCode,cashier:$Cashier | grep address | cut -d':' -f3 | xargs)

# set "static" vars
 everdev c r ./artifacts/Cashier.abi.json setGameCode -i _gameCode:$gameCode -a $Cashier
 everdev c r ./artifacts/Cashier.abi.json setGameDeployer -i _gameDeployer:$gameDeployer -a $Cashier

 everdev sol compile ./contracts/SlotDebot.sol -o ./artifacts
 SlotDebot=$(everdev contract deploy ./artifacts/SlotDebot.abi.json --value 4e8 -d gameCode:$gameCode,gameDeployer:$gameDeployer,cashier:$Cashier | grep address | cut -d':' -f3 | xargs)
 everdev contract run ./artifacts/SlotDebot.abi.json setABI --input "dabi:'$(cat ./artifacts/SlotDebot.abi.json | xxd -ps -c 20000)'" -a $SlotDebot
 ICON_BYTES=$(base64 -w 0 slotDebot.png)
 ICON=$(echo -n "data:image/png;base64,$ICON_BYTES" | xxd -ps -c 20000)
 everdev contract run ./artifacts/SlotDebot.abi.json setIcon --input "icon:'$ICON'" -a $SlotDebot

 echo "GameDeployer: 0:$gameDeployer"
 echo "Game: 0:$game"
 echo "Cashier: 0:$Cashier"
 echo "SlotDebot: 0:$SlotDebot"