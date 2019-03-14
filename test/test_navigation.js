var Application = require("spectron").Application;

describe("Application navigation", function () {
  this.timeout(30000);

  beforeEach(function () {
    this.app = new Application({
      path: `${__dirname}/../node_modules/.bin/electron`,
      args: ["app/main.js"]
    });
    return this.app.start();
  });

  afterEach(function () {
    if (this.app && this.app.isRunning()) {
      return this.app.stop();
    }
  });

  it("Should be able to click toplist button", function () {
    return this.app.client.click("#toplist-item");
  });

  it("Should be able to click search button", function () {
    return this.app.client.click("#search-item");
  });

  it("Should be able to click favourite button", function () {
    return this.app.client.click("#favourite-item");
  });

  it("Should be able to click settings button", function () {
    return this.app.client.click('#settings-item');
  });

  it("Should be able to click toggle button", function () {
    return this.app.client.click("#toggle-btn");
  });

  it("Should be able to click play button", function () {
    return this.app.client.click("#play-btn");
  });
});
