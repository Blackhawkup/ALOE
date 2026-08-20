import { afterEach, describe, expect, it, vi } from "vitest";

const ENV_KEY = "ALOE_CLIENT";

describe("USER_AGENT client tag", () => {
  const originalEnv = process.env[ENV_KEY];

  afterEach(() => {
    if (originalEnv === undefined) {
      delete process.env[ENV_KEY];
    } else {
      process.env[ENV_KEY] = originalEnv;
    }
    vi.resetModules();
  });

  // USER_AGENT is evaluated once at module load, so reset + re-import per case.
  async function loadUserAgent(): Promise<string> {
    vi.resetModules();
    return (await import("./version.js")).USER_AGENT;
  }

  it("is plain aloe/<version> when ALOE_CLIENT is unset", async () => {
    delete process.env[ENV_KEY];
    const ua = await loadUserAgent();
    expect(ua).toMatch(/^aloe\/\d+\.\d+\.\d+$/);
  });

  it("is unchanged when ALOE_CLIENT is empty/whitespace", async () => {
    process.env[ENV_KEY] = "   ";
    const ua = await loadUserAgent();
    expect(ua).toMatch(/^aloe\/\d+\.\d+\.\d+$/);
  });

  it("appends the client tag when ALOE_CLIENT is set", async () => {
    process.env[ENV_KEY] = "hermes-plugin/0.3.0";
    const ua = await loadUserAgent();
    expect(ua).toMatch(/^aloe\/\d+\.\d+\.\d+ hermes-plugin\/0\.3\.0$/);
  });

  it("sanitizes header-breaking characters from the client tag", async () => {
    process.env[ENV_KEY] = "hermes\r\nX-Injected: 1";
    const ua = await loadUserAgent();
    expect(ua).not.toMatch(/[\r\n]/);
    // Exactly one separator space; the tag itself contains no spaces or colons.
    expect(ua.split(" ")).toHaveLength(2);
    expect(ua).toContain("hermesX-Injected1");
  });
});
