module.exports = {
  defaultBrowser: "Firefox",
  rewrite: [
    {
      match: /maps\.google\.com\/maps\?hl=ja&q=(?:Seminar%20Area%20-%20https%3A%2F%2Fzoom\.kaizenplatform\.com%2F1srt|room%20[ABCD]%20-%20https%3A%2F%2Fzoom\.kaizenplatform\.com%2F\w+)&source=calendar/,
      url: ({ url }) => {
        const zoomUrl = url.search
          .split("&")
          .map((param) => param.split("="))
          .find((param) => param[0] == "q")[1];
        return decodeURIComponent(zoomUrl).split(" ").slice(-1)[0];
      },
    },
  ],
  handlers: [
    {
      match: ["www.typescriptlang.org/*", "docs.google.com/*"],
      browser: "Google Chrome",
    },
  ],
};
