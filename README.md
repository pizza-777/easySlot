# Slot DeBot

Easy slot machine writen on smart contracts.

### About deployment

#### deploy locally

Add surf1 signer (your surf wallet) to the signers list and run:

```bash
./l.sh # local
```

#### deploy in dev network

```bash
./d.sh # dev
```

debot in dev network ```0:cc4a01a3183c490172431a8adcda702d7d3d80df1e1a106f5f51ba183dad63ea```

#### RTP (return to player)

💎 🍌 🍎 🍊 🍉 🍋

Winning Combinations | No. of combos | Win | Payoff for 1 Ever | % Payoff |
--- | --- | --- | --- |--- |
3 💎 | 1 | 20 | 20 | 9.756%
Any 3 Fruit | 5 | 10 | 50 | 23.256%
2 💎 | 15 | 4 | 60 | 27.907%
1 💎 | 75 | 1 | 75 | 34.884%
Totals | 96 |  |  
% of Winning Combos | 44.444% | Payout |  205

RTP = (1 *20 + 5* 10 + 15 *4 + 75* 1)/(6 *6* 6) = 205/216 = 94.9%
