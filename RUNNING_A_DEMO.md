# Running a Demo of ALOE

This guide shows you how to quickly run a demo of ALOE (Adaptive LLM Orchestration Engine).

## Prerequisites

- Node.js (v22 or higher recommended)
- npm

## Quick Start (Standalone Proxy)

1. Install dependencies:

   ```bash
   npm install
   ```

2. Build the project:

   ```bash
   npm run build
   ```

3. Run the CLI / local proxy:

   ```bash
   node dist/cli.js
   # or
   npm run dev
   ```

   The local proxy will start on port 8402.

4. Test it out! Open a new terminal and send a request:
   ```bash
   curl -X POST http://localhost:8402/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "aloe/auto",
       "messages": [{"role": "user", "content": "Hello, how are you?"}]
     }'
   ```
   _Note: 5 models are free, so no wallet setup or API keys are required to test._

## Wallet Setup (Optional, for paid models)

If you want to use the paid models, ALOE auto-generates a wallet on the first run.
You can view your wallet details and manage funds via the CLI:

```bash
node dist/cli.js wallet
```
