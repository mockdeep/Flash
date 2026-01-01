import globals from "globals";
import importPlugin from "eslint-plugin-import";
import jest from "eslint-plugin-jest";
import js from "@eslint/js";
import stylistic from "@stylistic/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
import tseslint from "typescript-eslint";
import {defineConfig} from "eslint/config";
import sortKeysFix from "eslint-plugin-sort-keys-fix";
import eslintTodo from "./.eslint_todo";

export default defineConfig([
  js.configs.all,
  tseslint.configs.all,
  importPlugin.flatConfigs.recommended,
  jest.configs["flat/all"],
  stylistic.configs.all,
  {
    ignores: [
      ".eslint_todo.ts",
      "app/assets/builds/**",
      "babel.config.js",
      "coverage/**",
      "public/**",
      "vendor/**",
    ],
  },
  {
    files: ["**/*.{js,mjs,cjs,ts,mts,cts}"],
    languageOptions: {
      globals: globals.browser,
      parser: tsParser,
      parserOptions: {
        projectService: {
          allowDefaultProject: ["stylelint.config.mjs"],
        },
      },
    },
    plugins: {
      importPlugin,
      jest,
      js,
      "sort-keys-fix": sortKeysFix,
      stylistic,
    },
    rules: {
      "@stylistic/array-element-newline": ["error", "consistent"],
      "@stylistic/brace-style": ["error", "1tbs", {allowSingleLine: true}],
      "@stylistic/comma-dangle": ["error", "always-multiline"],
      "@stylistic/function-call-argument-newline": ["error", "consistent"],
      "@stylistic/indent": ["error", 2],
      "@stylistic/object-property-newline": ["error", {allowAllPropertiesOnSameLine: true}],
      "@stylistic/padded-blocks": ["error", "never"],
      "@stylistic/quote-props": ["error", "as-needed", {keywords: true}],
      "@stylistic/space-before-function-paren": ["error", {anonymous: "always", named: "never"}],
      "@typescript-eslint/explicit-member-accessibility": "off",
      "@typescript-eslint/naming-convention": "off",
      "@typescript-eslint/no-magic-numbers": "off",
      "@typescript-eslint/prefer-readonly-parameter-types": "off",
      "func-style": ["error", "declaration"],
      "jest/consistent-test-it": ["error", {fn: "it", withinDescribe: "it"}],
      "jest/prefer-expect-assertions": "off",
      "jest/require-top-level-describe": "off",
      "no-duplicate-imports": ["error", {allowSeparateTypeImports: true}],
      "no-magic-numbers": "off",
      "sort-imports": ["error", {ignoreCase: true, ignoreDeclarationSort: true}],
      "sort-keys": ["error", "asc", {caseSensitive: false, natural: true}],
      "sort-keys-fix/sort-keys-fix": ["error", "asc", {caseSensitive: false, natural: true}],
    },
    settings: {
      "import/resolver": {
        typescript: {
          alwaysTryTypes: true,
        },
      },
    },
  },
  {
    files: ["spec/javascript/test_helper.ts"],
    rules: {
      "jest/no-hooks": "off",
      "jest/no-standalone-expect": "off",
    },
  },
  {
    files: ["spec/javascript/support/**/*"],
    rules: {
      "jest/no-hooks": "off",
    },
  },
  {
    files: ["app/javascript/**/*.ts"],
    rules: {
      "jest/require-hook": "off",
    },
  },
  ...eslintTodo,
]);
