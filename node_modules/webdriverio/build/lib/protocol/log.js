'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.default = log;

var _ErrorHandler = require('../utils/ErrorHandler');

function log(type) {
    if (typeof type !== 'string' || type === '') {
        throw new _ErrorHandler.ProtocolError('number or type of arguments don\'t agree with log command');
    }

    return this.requestHandler.create('/session/:sessionId/log', {
        type: type
    });
} /**
   *
   * Get the log for a given log type. Log buffer is reset after each request.
   * (Not part of the official Webdriver specification).
   *
   * @param {String} type  The [log type](https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol#log-type). This must be provided.
   * @return {Object[]} The list of [log entries](https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol#log-entry-json-object)
   *
   * @see  https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol#sessionsessionidlog
   * @type protocol
   *
   */

module.exports = exports['default'];