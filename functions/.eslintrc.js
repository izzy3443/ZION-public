module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["./tsconfig.json", "./tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*",
    "/generated/**/*",
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "comma-dangle": "off",
    "no-multi-spaces": "off",
    "quotes": ["warn", "double"],                // Chill about single vs double quotes
    "import/no-unresolved": 0,                   // Don't warn about import paths
    "indent": ["warn", 2],                       // Warn on wrong indent, but don't block
    "object-curly-spacing": "off",               // Don't nag about spacing in { }
    "max-len": "off",                            // Let long lines live in peace
    "eol-last": "off",                           // Don't care about final newlines
    "no-trailing-spaces": "off",  
    "padded-blocks": "off", 
    'require-jsdoc': 'off',               // Don't stress about spaces at the end
  },
};
