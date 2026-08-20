#!/bin/bash
set -e

kill_port_processes() {
  local port="$1"
  local pids=""

  if command -v lsof >/dev/null 2>&1; then
    pids="$(lsof -ti :"$port" 2>/dev/null || true)"
  elif command -v fuser >/dev/null 2>&1; then
    pids="$(fuser "$port"/tcp 2>/dev/null || true)"
  elif command -v ss >/dev/null 2>&1; then
    pids="$(ss -lptn "sport = :$port" 2>/dev/null | sed -n 's/.*pid=\([0-9]\+\).*/\1/p' | sort -u)"
  elif command -v netstat >/dev/null 2>&1; then
    pids="$(netstat -nlpt 2>/dev/null | awk -v p=":$port" '$4 ~ p"$" {split($7,a,"/"); if (a[1] ~ /^[0-9]+$/) print a[1]}' | sort -u)"
  else
    echo "  Warning: could not find lsof/fuser/ss/netstat; skipping proxy stop"
    return 0
  fi

  if [ -n "$pids" ]; then
    echo "$pids" | xargs kill -9 2>/dev/null || true
  fi
}

echo "🦞 ALOE Uninstall"
echo ""

# 1. Stop proxy
echo "→ Stopping proxy..."
kill_port_processes 8402

# 2. Remove plugin files
echo "→ Removing plugin files..."
rm -rf ~/.openclaw/extensions/aloe

# 3. Clean openclaw.json
echo "→ Cleaning openclaw.json..."
node -e "
const os = require('os');
const fs = require('fs');
const path = require('path');
const configPath = path.join(os.homedir(), '.openclaw', 'openclaw.json');

if (!fs.existsSync(configPath)) {
  console.log('  No openclaw.json found, skipping');
  process.exit(0);
}

try {
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  let changed = false;

  // Remove aloe provider
  if (config.models?.providers?.aloe) {
    delete config.models.providers.aloe;
    console.log('  Removed aloe provider');
    changed = true;
  }

  // Remove plugin entries (check all case variants — OpenClaw stores PascalCase)
  for (const key of ['aloe', 'ALOE', 'aloe']) {
    if (config.plugins?.entries?.[key]) {
      delete config.plugins.entries[key];
      console.log('  Removed plugins.entries.' + key);
      changed = true;
    }
    if (config.plugins?.installs?.[key]) {
      delete config.plugins.installs[key];
      console.log('  Removed plugins.installs.' + key);
      changed = true;
    }
  }

  // Remove from plugins.allow
  if (Array.isArray(config.plugins?.allow)) {
    const before = config.plugins.allow.length;
    config.plugins.allow = config.plugins.allow.filter(
      p => p !== 'aloe' && p !== 'ALOE' && p !== 'aloe'
    );
    if (config.plugins.allow.length !== before) {
      console.log('  Removed from plugins.allow');
      changed = true;
    }
  }

  // Reset default model if it's aloe/auto
  if (config.agents?.defaults?.model?.primary === 'aloe/auto') {
    delete config.agents.defaults.model.primary;
    console.log('  Reset default model (was aloe/auto)');
    changed = true;
  }

  // Remove aloe models from allowlist
  if (config.agents?.defaults?.models) {
    const models = config.agents.defaults.models;
    let removedCount = 0;
    for (const key of Object.keys(models)) {
      if (key.startsWith('aloe/')) {
        delete models[key];
        removedCount++;
      }
    }
    if (removedCount > 0) {
      console.log('  Removed ' + removedCount + ' aloe models from allowlist');
      changed = true;
    }
  }

  if (changed) {
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log('  Config cleaned');
  } else {
    console.log('  No changes needed');
  }
} catch (err) {
  console.error('  Error:', err.message);
}
"

# 4. Clean auth-profiles.json
echo "→ Cleaning auth profiles..."
node -e "
const os = require('os');
const fs = require('fs');
const path = require('path');
const agentsDir = path.join(os.homedir(), '.openclaw', 'agents');

if (!fs.existsSync(agentsDir)) {
  console.log('  No agents directory found');
  process.exit(0);
}

const agents = fs.readdirSync(agentsDir, { withFileTypes: true })
  .filter(d => d.isDirectory())
  .map(d => d.name);

for (const agentId of agents) {
  const authPath = path.join(agentsDir, agentId, 'agent', 'auth-profiles.json');
  if (!fs.existsSync(authPath)) continue;

  try {
    const store = JSON.parse(fs.readFileSync(authPath, 'utf8'));
    if (store.profiles?.['aloe:default']) {
      delete store.profiles['aloe:default'];
      fs.writeFileSync(authPath, JSON.stringify(store, null, 2));
      console.log('  Removed aloe auth from ' + agentId);
    }
  } catch {}
}
"

# 5. Clean models cache
echo "→ Cleaning models cache..."
rm -f ~/.openclaw/agents/*/agent/models.json 2>/dev/null || true

echo ""
echo "✓ ALOE uninstalled"
echo ""
echo "Restart OpenClaw to apply changes:"
echo "  openclaw gateway restart"
