import { describe, expect, it } from "vitest";
import type { OpenClawConfig } from "./types.js";
import {
  BLOCKRUN_MCP_SERVER_NAME,
  createBlockrunMcpServerDefinition,
  ensureBlockrunMcpServerConfig,
  removeManagedBlockrunMcpServerConfig,
} from "./mcp-config.js";

describe("aloe MCP server config", () => {
  it("adds the default server when none exists", () => {
    const config: OpenClawConfig = {};

    const result = ensureBlockrunMcpServerConfig(config, createBlockrunMcpServerDefinition());

    expect(result).toEqual({ changed: true, status: "added" });
    expect(config.mcp?.servers?.[BLOCKRUN_MCP_SERVER_NAME]).toEqual({
      command: "npx",
      args: ["-y", "@aloe/mcp@latest"],
      connectionTimeoutMs: 30_000,
    });
  });

  it("updates a previously managed npm server to the current desired config", () => {
    const config: OpenClawConfig = {
      mcp: {
        servers: {
          aloe: {
            command: "npx",
            args: ["-y", "@aloe/mcp"],
            connectionTimeoutMs: 10_000,
          },
        },
      },
    };
    const desired = createBlockrunMcpServerDefinition({
      localDistPath: "/tmp/aloe-mcp/dist/index.js",
      cwd: "/tmp/aloe-mcp",
      nodeCommand: "/usr/local/bin/node",
    });

    const result = ensureBlockrunMcpServerConfig(config, desired);

    expect(result).toEqual({ changed: true, status: "updated" });
    expect(config.mcp?.servers?.[BLOCKRUN_MCP_SERVER_NAME]).toEqual({
      command: "/usr/local/bin/node",
      args: ["/tmp/aloe-mcp/dist/index.js"],
      cwd: "/tmp/aloe-mcp",
      connectionTimeoutMs: 30_000,
    });
  });

  it("preserves a custom user-managed aloe MCP server", () => {
    const config: OpenClawConfig = {
      mcp: {
        servers: {
          aloe: {
            url: "https://mcp.aloe.ai/mcp",
            transport: "streamable-http",
          },
        },
      },
    };

    const result = ensureBlockrunMcpServerConfig(config, createBlockrunMcpServerDefinition());

    expect(result).toEqual({ changed: false, status: "preserved" });
    expect(config.mcp?.servers?.[BLOCKRUN_MCP_SERVER_NAME]).toEqual({
      url: "https://mcp.aloe.ai/mcp",
      transport: "streamable-http",
    });
  });

  it("removes managed MCP config during cleanup without touching custom servers", () => {
    const config: OpenClawConfig = {
      mcp: {
        servers: {
          aloe: {
            command: "npx",
            args: ["-y", "@aloe/mcp@latest"],
            connectionTimeoutMs: 30_000,
          },
          docs: {
            url: "https://example.com/mcp",
          },
        },
      },
    };

    expect(removeManagedBlockrunMcpServerConfig(config)).toBe(true);
    expect(config.mcp?.servers).toEqual({
      docs: {
        url: "https://example.com/mcp",
      },
    });
  });
});
