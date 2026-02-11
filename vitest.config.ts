import {resolve} from "node:path";
import {defineConfig} from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      channels: resolve(__dirname, "app/javascript/channels"),
      controllers: resolve(__dirname, "app/javascript/controllers"),
      javascript: resolve(__dirname, "app/javascript"),
      "spec/javascript": resolve(__dirname, "spec/javascript"),
    },
  },
  test: {
    coverage: {
      exclude: ["app/javascript/@types/**"],
      include: ["app/javascript/**/*.ts"],
      provider: "v8",
      reporter: ["html"],
      reportsDirectory: "coverage/vitest",
      thresholds: {
        branches: 100,
        functions: 100,
        lines: 0,
        statements: 0,
      },
    },
    environment: "jsdom",
    environmentOptions: {
      jsdom: {
        url: "http://test.host",
      },
    },
    include: ["spec/javascript/**/*_spec.ts"],
    mockReset: true,
    restoreMocks: true,
    setupFiles: ["spec/javascript/test_helper.ts"],
  },
});
