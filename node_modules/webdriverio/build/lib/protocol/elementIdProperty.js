'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.default = elementIdProperty;

var _ErrorHandler = require('../utils/ErrorHandler');

var _utilities = require('../helpers/utilities');

/**
 *
 * Get the value of an element's property.
 *
 * @param {String} ID             ID of a WebElement JSON object to route the command to
 * @param {String} propertyName  property name of element you want to receive
 *
 * @return {String|null} The value of the property, or null if it is not set on the element.
 *
 * @see  https://w3c.github.io/webdriver/webdriver-spec.html#dfn-get-element-property
 * @type protocol
 *
 */

function elementIdProperty(id, propertyName) {
    var _this = this;

    if (typeof id !== 'string' && typeof id !== 'number' || typeof propertyName !== 'string') {
        throw new _ErrorHandler.ProtocolError('number or type of arguments don\'t agree with elementIdProperty protocol command');
    }

    return this.requestHandler.create(`/session/:sessionId/element/${id}/property/${propertyName}`).catch(function (err) {
        /**
         * use old path if W3C path failed
         */
        if ((0, _utilities.isUnknownCommand)(err)) {
            return _this.elementIdAttribute(id, propertyName);
        }

        throw err;
    });
}
module.exports = exports['default'];