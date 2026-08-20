# Workflow & Working Mechanism

This document outlines the step-by-step workflow of how ALOE processes an LLM request from inception to completion.

## 1. Request Interception
The lifecycle begins when an AI agent or a developer tool (like Cursor or Continue.dev) sends an OpenAI-compatible request to ALOE's local proxy running on `http://localhost:8402`. The request is intercepted and parsed. 

## 2. Model Resolution & Smart Routing
If the user specifically pinned a model (e.g., `model: "free/mistral-nemotron"`), ALOE respects the choice and prepares to route directly to that provider.
If the user selected a routing profile (e.g., `model: "aloe/auto"` or `model: "aloe/eco"`), the request enters the **Smart Routing Engine**:
- **Heuristic Scoring**: The engine evaluates the request across 15 dimensions (context length, required reasoning, vision requirements, system prompt complexity).
- **Tier Assignment**: The request is categorized into a complexity tier (SIMPLE, MEDIUM, COMPLEX, REASONING).
- **Model Selection**: Based on the tier and the chosen profile, the router dynamically selects the most cost-effective model that satisfies the criteria.

## 3. Pre-flight & Authentication (x402 Protocol)
Unlike traditional routers that append a Bearer token API key, ALOE uses the **x402 Micropayments Protocol**:
1. ALOE attempts a request to the target model's upstream gateway.
2. The gateway responds with an `HTTP 402 Payment Required` status, indicating the exact price for the request (e.g., $0.003 USDC).
3. ALOE's local payment layer intercepts this 402 response, uses its locally derived wallet, and cryptographically signs a transaction for the required amount.
4. The signed transaction is sent back in the header as proof of payment.

## 4. Execution & Streaming
Once the gateway verifies the cryptographic signature and settles the micro-transaction, it processes the prompt.
The response from the target LLM is streamed back to ALOE, which seamlessly forwards the stream to the original client.

## 5. Post-Execution & Caching
ALOE logs the transaction details (latency, exact token usage, cost) for local statistics tracking (viewable via `/stats`). Successful responses may also be locally cached to further eliminate costs and latency on identical future requests.
