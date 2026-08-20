#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "🐳 Building Docker installation test environment..."
docker build -f test/Dockerfile.install-test -t aloe-install-test .

echo ""
echo "🧪 Running installation tests..."
docker run --rm aloe-install-test /home/testuser/docker-install-tests.sh

echo ""
echo "✅ Installation tests completed successfully!"
