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
    "selector-class-pattern": [
      "^[a-z][a-z0-9]*(-[a-z0-9]+)*" +
      "(__[a-z0-9]+(-[a-z0-9]+)*)?" +
      "(--[a-z0-9]+(-[a-z0-9]+)*)?$",
      {
        message:
          "Expected class selector to follow BEM naming" +
          " (block__element--modifier)",
      },
    ],
  },
};
