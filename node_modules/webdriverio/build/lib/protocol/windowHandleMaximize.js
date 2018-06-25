'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _utilities = require('../helpers/utilities');

var windowHandleMaximize = function windowHandleMaximize() {
    var _this = this;

    var windowHandle = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'current';

    var requestOptions = {
        path: `/session/:sessionId/window/${windowHandle}/maximize`,
        method: 'POST'
    };

    return this.requestHandler.create(requestOptions).catch(function (err) {
        /**
         * use W3C path if old path failed
         */
        if ((0, _utilities.isUnknownCommand)(err)) {
            requestOptions.path = '/session/:sessionId/window/maximize';
            return _this.requestHandler.create(requestOptions);
        }

        throw err;
    });
}; /**
    *
    * Maximize the specified window if not already maximized. If the :windowHandle URL parameter is "current",
    * the currently active window will be maximized.
    *
    * <example>
       :windowMaximize.js
       it('should maximize the passed window handle', function () {
           // get current window handle
           var windowHandle = browser.windowHandle();
           console.log(windowHandle);
   
           // outputs something like the following:
           //  {
           //      state: 'success',
           //      sessionId: 'e6782264-9eb1-427b-9250-d8302ac35161',
           //      hCode: 988127308,
           //      value: 'CDwindow-849D79B1-5CCB-4A1D-A217-5BA809D935F3',
           //      class: 'org.openqa.selenium.remote.Response',
           //      status: 0
           //  }
   
           // pass windowHandle.value to windowHandleMaximize
           browser.windowHandleMaximize('{'+windowHandle.value+'}');
       });
    * </example>
    * @param {String=} windowHandle window to maximize (if parameter is falsy the currently active window will be maximized)
    *
    * @see  https://w3c.github.io/webdriver/webdriver-spec.html#dfn-maximize-window
    * @type protocol
    *
    */

exports.default = windowHandleMaximize;
module.exports = exports['default'];