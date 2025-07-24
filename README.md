# Aptos Gamefied Prediction Market For Memes

Gamified prediction market where users bet on whether memes will go viral within a week, earning rewards in Aptos Coin. By integrating blockchain-powered betting with meme culture, AptosOdds transforms viral content into a decentralized economy that rewards creators and engaged communities.

## Contact
If you have any question, contact here: [Telegram](https://t.me/shiny0103) | [Twitter](https://x.com/0xTan1319)

## Related projects

- [Frontend](https://github.com/0xTan1319/meme-prediction-market-fe-aptos)
- [Backend](https://github.com/0xTan1319/meme-prediction-market-be-aptos)

## Features
- Bet on the virality of trending memes
- Weekly prediction rounds
- Rewards distributed in Aptos Coin
- Transparent and decentralized using Aptos blockchain
- Community-driven meme selection and voting

## How It Works
1. **Meme Selection:** Memes are nominated and selected for each weekly round.
2. **Betting:** Users place bets on whether a meme will go viral (reach a certain threshold of engagement) within the week.
3. **Resolution:** At the end of the week, the contract checks if the meme met the virality criteria.
4. **Rewards:** Winners share the prize pool, distributed automatically by the smart contract.

## Smart Contract Structure
- **PredictionMarket.move:** Main contract handling bets, rounds, and reward distribution.
- **MemeRegistry.move:** Manages meme nominations and selection.
- **Utils.move:** Helper functions for calculations and validations.

## Getting Started
### Prerequisites
- [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/)
- Rust (for Move compiler)
- Node.js (for frontend, if applicable)

### Installation
```bash
# Clone the repository
$ git clone https://github.com/0xTan1319/meme-prediction-market-contract-aptos.git
$ cd meme-prediction-market-contract-aptos

# Install dependencies (if any)
# ...
```

## Usage
### Deploying the Contract
```bash
# Compile Move modules
$ aptos move compile

# Publish to Aptos testnet
$ aptos move publish --profile testnet
```

## Testing
```bash
# Run Move unit tests
$ aptos move test
```

## Contributing
Contributions are welcome! Please open issues or submit pull requests for improvements and new features.

## License
This project is licensed under the MIT License. See [LICENSE](../LICENSE) for details.


