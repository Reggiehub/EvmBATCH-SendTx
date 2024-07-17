#!/bin/bash

BOLD_BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${BOLD_BLUE}Checking Node.js and npm installation...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${BOLD_BLUE}Node.js is not installed. Please install Node.js.${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${BOLD_BLUE}npm is not installed. Please install npm.${NC}"
    exit 1
fi

echo -e "${BOLD_BLUE}Creating project directory and navigating into it...${NC}"
mkdir -p UnitBatchTx
cd UnitBatchTx

echo -e "${BOLD_BLUE}Initializing a new Node.js project...${NC}"
npm init -y > /dev/null

echo -e "${BOLD_BLUE}Installing required packages...${NC}"
npm install web3 chalk readline-sync

echo -e "${BOLD_BLUE}Prompting for private key and receiver address...${NC}"
read -sp "Enter your Ethereum private key: " privkey
echo
read -p "Enter the receiver's Ethereum address: " receiver

echo -e "${BOLD_BLUE}Creating the Node.js script file...${NC}"
cat << EOF > unit.mjs
import Web3 from 'web3';
import chalk from 'chalk';
import readlineSync from 'readline-sync';

const rpcUrl = 'https://rpc-testnet.unit0.dev';
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

const senderPrivateKey = '$privkey';
const senderAddress = web3.eth.accounts.privateKeyToAccount(senderPrivateKey).address;
const receiverAddress = '$receiver';

const sendEther = async (fromAddress, toAddress, amountInEther, privateKey) => {
  const txCount = await web3.eth.getTransactionCount(fromAddress);
  const tx = {
    from: fromAddress,
    to: toAddress,
    value: web3.utils.toWei(amountInEther.toString(), 'ether'),
    gas: 21000,
    nonce: txCount
  };

  const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
  const txHash = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
  console.log(chalk.blue('Tx hash:'), txHash.transactionHash);
};

(async () => {
  const txCount = 100; // The number of transactions to send
  for (let i = 0; i < txCount; i++) {
    try {
      await sendEther(senderAddress, receiverAddress, 0.000001, senderPrivateKey);
      const randomDelay = Math.floor(Math.random() * 3) + 1; // Random delay between 1 to 3 seconds
      await new Promise(resolve => setTimeout(resolve, randomDelay * 1000));
    } catch (error) {
      console.error(chalk.red('Error sending transaction:'), error);
    }
  }
})();
EOF

echo -e "${BOLD_BLUE}Executing the Node.js script...${NC}"
node unit.mjs
