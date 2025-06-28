module.exports = {
  defaultBrowser: "Firefox",
  rewrite: [],
  handlers: [
    {
      match: ["www.typescriptlang.org/*", "docs.google.com/*"],
      browser: "Google Chrome",
    },
  ],
};
