var Application = require("spectron").Application;

describe("Application navigation", function () {
  this.timeout(30000);

  beforeEach(function () {
    this.app = new Application({
      path: `${__dirname}/../node_modules/.bin/electron`,
      args: ["main.js"]
    });
    return this.app.start();
  });

  afterEach(function () {
    if (this.app && this.app.isRunning()) {
      return this.app.stop();
    }
  });

  it("Should be able to click toplist button", function () {
    return this.app.client.waitForVisible('#toplist-item', 30000).element("#toplist-item").click();
  });

  it("Should be able to click search button", function () {
    return this.app.client.waitForVisible('#search-item', 30000).element("#search-item").click();
  });

  it("Should be able to click favourite button", function () {
    return this.app.client.waitForVisible('#favourite-item', 30000).element("#favourite-item").click();
  });

  it("Should be able to click about button", function () {
    return this.app.client.waitForVisible('#about-item', 30000).element("#about-item").click();
  });

  it("Should be able to click toggle button", function () {
    return this.app.client.waitForVisible('#toggle-btn', 30000).element("#toggle-btn").click();
  });

  it("Should be able to click play button", function () {
    return this.app.client.waitForVisible('#play-btn', 30000).element("#play-btn").click();
  });
});
