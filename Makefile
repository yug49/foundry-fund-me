-include .env

build :; forge build

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit

deploy :
	forge script script/DeployFundMe.s.sol:DeployFundMe -vvvv

deploy-sepolia :
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

zkbuild :; forge build --zksync

test :; forge test

test-coverage :; forge coverage

zktest :; foundryup-zksync && forge test --zksync && foundryup

anvil :; anvil

zk-sync-anvil :; foundryup-zksync && anvil	
# always run `foundryup` after closing zk-sync-anvil

snapshot :; forge snapshot

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"