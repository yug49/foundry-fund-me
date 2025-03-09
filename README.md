
# foundry-fund-me
It is a smart contract project written in [Solidity](https://docs.soliditylang.org/en/latest/) using [Foundry](https://book.getfoundry.sh/).
- It a smart contract which can take fundings from different users and the owner(the user who deployed the contract) can withdraw all the value the the contract holds into his account.


## Getting Started

 - [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git): You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
 - [foundry](https://getfoundry.sh/): You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`
 - [make](https://www.gnu.org/software/make/manual/make.html) (optional - either you can install `make` or you can simply substitute the make commands with forge commands by referring to the Makefile after including your .env file): You'll know you did it right if you can run `make --version` and you will see a response like `GNU Make 3.81...`

 
## Installation

- Install foundry-fund-me
```bash
    git clone https://github.com/yug49/foundry-fund-me-f23
    cd foundry-fund-me
```

- Make a .env file
```bash
    touch .env
```

- Open the .env file and fill in the details similar to:
```env
    SEPOLIA_RPC_URL=<YOUR SEPOLIA RPC URL>
    MAINNET_RPC_URL=<YOUR MAINNET RPC URL>
    ETHERSCAN_API_KEY=<YOUR ETHERSCAN API KEY>
    PRIVATE_KEY=<YOUR PRIVATE KEY>
```

- Install dependencies and libraries
```bash
    make install
```

    
## Usage

### Deploy

```bash
make deploy
```

### Testing

- for local anvil
```bash
    make test
```

- for zksync (only testing works for now not zk-sync deploy)
```bash
    make zktest
```

### Coverage

```bash
make test-coverage
```




## Deployment to a testnet or mainnet
- You must have your `.env` file ready as told in installation section
- If pushing on github, DO NOT FORGET to add the `.env` file in the `.gitignore`

### Sepolia Testnet
```bash
make deploy-sepolia
```

### Mainnet
```bash
make deploy-mainnet
``` 

### Scripts
After deploying, you can run the scripts.

Using cast:

```bash
cast send <FUNDME_CONTRACT_ADDRESS> "fund()" --value 0.1ether --private-key <PRIVATE_KEY>
cast send <FUNDME_CONTRACT_ADDRESS> "withdraw()"  --private-key <PRIVATE_KEY>
```
or
```bash
forge script script/Interactions.s.sol:FundFundMe --rpc-url sepolia  --private-key $PRIVATE_KEY  --broadcast
forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url sepolia  --private-key $PRIVATE_KEY  --broadcast
```

### Estimate gas
You can estimate how much gas things cost by running:
```bash
make snapshot
```

## Formatting
To run code Formatting
```bash
forge fmt
```
## 🔗 Links
Loved it? lets connect on:

[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://x.com/yugAgarwal29)
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/yug-agarwal-8b761b255/)

