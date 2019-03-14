(function () {
  const remote = require("electron").remote;

  function init() {
    const window = remote.getCurrentWindow();
    document.getElementById("min-btn").addEventListener("click", function (e) {
      window.minimize();
    });

    document.getElementById("max-btn").addEventListener("click", function (e) {
      if (!window.isMaximized()) {
        window.maximize();
      } else {
        window.unmaximize();
      }
    });

    document.getElementById("close-btn").addEventListener("click", function (e) {
      window.close();
    });
  }

  document.onreadystatechange = function () {
    if (document.readyState == "complete") {
      init();
    }
  };
})();
