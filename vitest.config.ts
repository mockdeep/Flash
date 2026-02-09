import {defineConfig} from "vitest/config";
import path from "node:path";

const root = import.meta.dirname;

function appPath(subpath: string): string {
  return `${path.resolve(root, "app/javascript", subpath)}/`;
}

export default defineConfig({
  resolve: {
    alias: [
      {find: /^channels\//u, replacement: appPath("channels")},
      {find: /^controllers\//u, replacement: appPath("controllers")},
      {find: /^javascript\//u, replacement: appPath("")},
      {find: /^spec\//u, replacement: `${path.resolve(root, "spec")}/`},
    ],
  },
  test: {
    coverage: {
      exclude: ["app/javascript/@types/**"],
      include: ["app/javascript/**/*.ts"],
      provider: "v8",
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
    outputFile: {
      junit: "/tmp/test-results/junit.xml",
    },
    reporters: ["default", "junit"],
    restoreMocks: true,
    root: ".",
    setupFiles: ["spec/javascript/test_helper.ts"],
  },
});
