## Kaia Chain Oracle Toolkit
Welcome to the Kaia Chain Oracle Toolkit, a repository containing sample code for integrating Oracles into decentralized applications (dApps) built on the Kaia Chain. This toolkit provides two key integration examples:

### Orakl Integration: 
Demonstrates how to fetch and utilize off-chain data using Orakl, a decentralized Oracle solution.
### Pyth Price Feed: 
Provides sample code for accessing real-time price feeds using the Pyth Network.

### Purpose
The purpose of this toolkit is to simplify the integration of off-chain data into your Kaia Chain-based dApps by offering ready-to-use examples. With these examples, developers can easily add decentralized price feeds or other external data sources to their smart contracts, enabling advanced functionality and improving the reliability of data in decentralized finance (DeFi) or other decentralized applications.

### Features
### Orakl Integration:
A demonstration of how to connect to Orakl to retrieve off-chain data for smart contracts on the Kaia Chain.

### Pyth Price Feed:
Provides an example of how to integrate the Pyth price feed into your dApp to access real-time price data for various assets.

### Installation
To get started with the toolkit, clone the repository and install the necessary dependencies.

```bash
git clone https://github.com/PaulElisha/Kaia-Toolkit-Oracle.git
cd Kaia-Toolkit-toolkit
forge install
```

### Usage
1. Orakl Integration
The Orakl integration sample demonstrates how to pull off-chain data and make it accessible in a Kaia Chain smart contract.

Navigate to the orakl-integration directory to view the implementation.
Deploy the contract with Foundry and interact with the Oracle to fetch external data.

```bash
forge build
forge test
```
1. Pyth Price Feed Integration
The Pyth Price Feed sample provides code that allows a dApp to retrieve live price information of various assets.

Navigate to the pyth-price-feed directory to explore the example.
Deploy the smart contract and connect it to Pyth’s price feed to access accurate and real-time price data.

```bash
forge build
forge test
```

### Prerequisites
Before using this toolkit, make sure you have the following installed:

Foundry
Solidity
Access to a Kaia Chain development environment.
Contributions
We welcome contributions to improve the toolkit or add new Oracle integrations! If you'd like to contribute:

Fork the repository.
Create a new branch.
Commit your changes.
Open a Pull Request.
License
This project is licensed under the MIT License. See the LICENSE file for more details.