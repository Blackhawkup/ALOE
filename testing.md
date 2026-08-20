# Testing Strategy & Test Suites

This document outlines the testing methodologies used in the ALOE project. Robust testing is critical because ALOE manages live financial transactions (via x402) and acts as the critical path between autonomous agents and their cognitive engines (LLMs).

## Testing Framework
We use **Vitest** for our test runner due to its native ESM support, execution speed, and seamless integration with TypeScript. 

## Types of Tests Implemented

### 1. Proxy & Routing Tests (`src/proxy.*.test.ts`, `src/router/*.test.ts`)
- **What they do:** Test the core 15-dimension classifier and the routing logic. They ensure that given a specific prompt, the router correctly assigns a tier (SIMPLE, MEDIUM, COMPLEX, REASONING) and selects the appropriate model.
- **Why these tests?** The core value proposition of ALOE is saving costs without degrading quality. We must mathematically prove that the routing profiles (`eco`, `auto`, `premium`) behave deterministically.
- **Coverage:** Streaming deduplication, token capping, reasoning headers processing, and model downgrade failovers.

### 2. Wallet & Payment Pre-auth Tests (`src/wallet.test.ts`, `src/payment-preauth.test.ts`)
- **What they do:** Validate BIP-39 mnemonic generation, key derivation for both EVM and Solana, and x402 signature generation.
- **Why these tests?** Financial security is non-negotiable. These tests ensure that signatures are structurally valid and that private keys are derived correctly according to standard paths (m/44'/60'/0'/0/0 for EVM, m/44'/501'/0'/0' for Solana) to prevent loss of funds.

### 3. Caching & Resilience Tests (`src/response-cache.*.test.ts`)
- **What they do:** Simulate high-concurrency requests and evaluate ALOE's caching layer.
- **Why these tests?** A local proxy must be highly performant. These tests ensure that identical requests fetch from the cache rather than triggering redundant, expensive downstream LLM network calls, verifying both cost savings and sub-millisecond latencies.

### 4. Spend Control Tests (`src/spend-control.test.ts`)
- **What they do:** Validate that the budget limits per request are enforced.
- **Why these tests?** Prevents agents from accidentally spending unbounded amounts of USDC in an infinite loop or high-context hallucination scenario.

## Why this testing approach?
We emphasize **integration and behavioral testing** over pure unit testing. Because the system's complexity lies in the orchestration of network boundaries (HTTP to upstream LLMs, RPCs to blockchains), mocking every component provides false confidence. Instead, we use controlled stubs for network requests while executing the full ALOE internal pipeline (from proxy intercept -> router -> wallet sign -> response stream).
