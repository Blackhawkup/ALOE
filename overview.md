# ALOE: Project Overview

## What is ALOE?

ALOE (Adaptive LLM Orchestration Engine) is an open-source, local HTTP proxy designed to act as a smart router for AI agents. Rather than connecting directly to a single LLM provider like OpenAI or Anthropic, an agent connects to ALOE. ALOE then dynamically evaluates every prompt and routes it to the most cost-effective and capable model out of a pool of 70+ models.

## Why was ALOE created?

Traditional LLM routing requires human intervention: signing up for accounts, generating API keys, and entering credit cards. ALOE was built to give AI agents true financial and operational autonomy.

## How does it work?

1. **Intercept:** The agent sends a standard OpenAI-formatted request to ALOE's local server.
2. **Score & Route:** ALOE's 15-dimension classifier evaluates the complexity of the prompt and selects the best model based on the user's chosen profile (`eco`, `auto`, or `premium`).
3. **Pay:** ALOE utilizes the x402 micropayments protocol. Using a locally derived cryptocurrency wallet, ALOE cryptographically signs a micro-transaction (in USDC on Base or Solana) to pay for the specific request. No centralized API keys are used.
4. **Respond:** The response from the target model is streamed back to the agent seamlessly.

## Core Technologies

- **Node.js & TypeScript:** Fast, async-optimized local execution and strong type safety.
- **x402 Protocol:** The micropayment standard that replaces API keys with wallet signatures.
- **EVM (Base) & Solana:** High-speed, low-cost blockchain networks used for settling the USDC micropayments.

## Results & Impact

By using ALOE, an autonomous agent can reduce its LLM API inference costs by **88%** on average. Because routing decisions are made locally in under 1 millisecond, this cost reduction comes with zero performance penalty. ALOE successfully proves that agents can operate entirely independently, managing their own wallets and optimizing their own intelligence pipelines.
