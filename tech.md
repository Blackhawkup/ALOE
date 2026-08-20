# Technology Stack & Choices

This document explains the core technology choices made in the ALOE project and the rationale behind them.

## Core Language & Runtime
**Choice: TypeScript & Node.js**
- **Why?** ALOE operates heavily as an intermediary HTTP proxy between the agent and upstream AI APIs. Node.js is highly optimized for network-bound asynchronous I/O operations. TypeScript provides strong type safety, enabling robust handling of complex LLM response schemas, streaming protocols, and Web3 cryptographic operations.
- **Why not Python?** While Python is dominant in ML/AI training, its synchronous blocking nature in basic web servers (without moving to specialized ASGI frameworks) makes it less suited for a high-concurrency local proxy streaming tokens in real-time. 

## Payment Protocol
**Choice: x402 Micropayments Protocol**
- **Why?** Traditional API keys require a centralized account, credit card setups, and pre-funded balances. Agents cannot sign up for bank accounts. The x402 protocol allows ALOE to sign HTTP requests with cryptographic signatures and attach per-request micro-transactions. This is the only protocol that enables true agent autonomy.
- **Why not Stripe / traditional fiat?** Fiat rails do not support micro-transactions on the order of $0.0001 effectively due to processing fees, and they enforce strict KYC/AML bottlenecks that autonomous agents cannot clear.

## Blockchain Networks
**Choice: Base (EVM) & Solana (USDC)**
- **Why?** ALOE leverages the Base L2 network and Solana for settling USDC transactions. Both networks offer sub-cent gas fees and sub-second finality. 
- **Why not Ethereum Mainnet?** The gas fees on Ethereum L1 ($1 to $50+) would completely eclipse the cost of the AI API calls ($0.001), rendering micropayments impossible.

## Cryptography & Wallet Management
**Choice: @scure/bip39, @scure/bip32, viem, @solana/kit**
- **Why?** ALOE must manage private keys locally to sign x402 requests. `@scure` libraries provide highly audited, dependency-free implementations of BIP-39 mnemonic generation. `viem` is chosen over `ethers.js` for EVM interactions due to its significantly smaller bundle size and functional API, which improves proxy startup time. `@solana/kit` handles the Solana equivalent natively.

## Testing Framework
**Choice: Vitest**
- **Why?** ALOE heavily uses TypeScript and ES modules. Vitest provides native ESM support, out-of-the-box TypeScript execution without slow compilation steps (unlike Jest), and a compatible API that allows for rapid execution of our resilience and routing tests.
