var Application = require("spectron").Application;
var assert = require("assert");

describe("Application launch", function () {
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

  it("Should start and display a visible window", function () {
    return this.app.browserWindow.isVisible().then(function (isVisible) {
      assert.equal(isVisible, true);
    });
  });

  it("Should show one window", function () {
    return this.app.client.getWindowCount().then(function (count) {
      assert.equal(count, 1);
    });
  });

  it("Title should be correct", function () {
    return this.app.client.getTitle().then(function (title) {
      assert.equal(title, "Poddr");
    });
  });
});