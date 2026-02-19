export default {
  "extends": [
    "stylelint-config-recess-order",
    "stylelint-config-standard",
    "stylelint-selector-bem-pattern",
    "./.stylelint_wishlist.yml",
    "./.stylelint_todo.yml",
  ],
  plugins: ["stylelint-selector-bem-pattern"],
  rules: {
    "import-notation": "string",
  },
};
