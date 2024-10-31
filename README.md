# Tokenized Loyalty and Rewards Program

## Overview

This project implements a tokenized loyalty program where businesses can reward customers with tokens that can be redeemed for products or services. The program is implemented as a smart contract with accompanying tests.

## Key Features

- Reward points in tokens
- Token redemption options
- Staking for bonus rewards
- Multi-business integration

## Project Structure

- `loyalty-program.clar`: The Clarity smart contract implementing the loyalty program (not included in this repository)
- `loyalty-program.test.js`: Vitest tests for the loyalty program functionality

## Prerequisites

- Node.js (v14 or later recommended)
- npm (comes with Node.js)

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/your-username/tokenized-loyalty-program.git
   cd tokenized-loyalty-program
   ```

2. Install dependencies:
   ```
   npm install
   ```

## Running Tests

To run the tests, use the following command:

```
npm test
```

This will execute the Vitest test suite and display the results in your terminal.

## Smart Contract Functions

The loyalty program smart contract (simulated in the tests) includes the following main functions:

- `registerBusiness(business)`: Register a new business in the loyalty program
- `mintAndDistribute(business, recipient, amount)`: Mint and distribute tokens to a user
- `redeemTokens(user, amount)`: Allow a user to redeem tokens
- `stakeTokens(user, amount)`: Allow a user to stake tokens for bonus rewards
- `unstakeTokens(user)`: Allow a user to unstake tokens and claim bonuses
- `isBusiness(address)`: Check if an address is a registered business
- `getStakedBalance(address)`: Get the staked balance of an address
- `getStakingStartTime(address)`: Get the staking start time of an address

## Test Coverage

The test suite covers the following scenarios:

1. Business registration
2. Token minting and distribution
3. Token redemption
4. Token staking
5. Unstaking and bonus claiming
6. Business status checking
7. Staked balance retrieval
8. Staking start time retrieval

## Future Improvements

- Implement the actual Clarity smart contract
- Add more complex staking mechanics
- Implement tiered rewards
- Add transfer functionality between users
- Integrate with a front-end application

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
