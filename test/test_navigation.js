var Application = require("spectron").Application;
var assert = require("assert");

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
    return this.app.client.element("#toplist-item").click();
  });

  it("Should be able to click search button", function () {
    return this.app.client.element("#search-item").click();
  });

  it("Should be able to click favourite button", function () {
    return this.app.client.element("#favourite-item").click();
  });

  it("Should be able to click about button", function () {
    return this.app.client.element("#about-item").click();
  });

  it("Should be able to click toggle button", function () {
    return this.app.client.element("#toggle-btn").click();
  });

  it("Should be able to click play button", function () {
    return this.app.client.element("#play-btn").click();
  });
});
