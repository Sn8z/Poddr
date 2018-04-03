'use strict';

var _isWithinViewport = require('../scripts/isWithinViewport');

var _isWithinViewport2 = _interopRequireDefault(_isWithinViewport);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

module.exports = function isVisibleWithinViewport(selector) {
    var _this = this;

    /**
     * check if we already queried the element within a prior command, in these cases
     * the selector attribute is null and the element can be recieved calling the
     * `element` command again
     */
    var resultPromise = void 0;
    if (selector === null) {
        resultPromise = this.elements(selector).then(function (res) {
            return _this.execute(_isWithinViewport2.default, res.value);
        }).then(function (result) {
            return result.value;
        });
    } else {
        resultPromise = this.selectorExecute(selector, _isWithinViewport2.default);
    }

    return resultPromise.then(function (res) {
        if (Array.isArray(res) && res.length === 1) {
            return res[0];
        }

        return res;
    }, function (err) {
        /**
         * if element does not exist it is automatically not visible :-)
         */
        if (err.message.indexOf('NoSuchElement') > -1) {
            return false;
        }

        throw err;
    });
}; /**
    *
    * Return true if the selected DOM-element found by given selector is visible and within the viewport.
    *
    * <example>
       :index.html
       <div id="notDisplayed" style="display: none"></div>
       <div id="notVisible" style="visibility: hidden"></div>
       <div id="notInViewport" style="position:absolute; left: 9999999"></div>
       <div id="zeroOpacity" style="opacity: 0"></div>
   
       :isVisibleWithinViewport.js
       :isVisible.js
       it('should detect if an element is visible', function () {
           var isVisibleWithinViewport = browser.isVisibleWithinViewport('#notDisplayed');
           console.log(isVisibleWithinViewport); // outputs: false
   
           isVisibleWithinViewport = browser.isVisibleWithinViewport('#notVisible');
           console.log(isVisibleWithinViewport); // outputs: false
   
           isVisibleWithinViewport = browser.isVisibleWithinViewport('#notExisting');
           console.log(isVisibleWithinViewport); // outputs: false
   
           isVisibleWithinViewport = browser.isVisibleWithinViewport('#notInViewport');
           console.log(isVisibleWithinViewport); // outputs: false
   
           isVisibleWithinViewport = browser.isVisibleWithinViewport('#zeroOpacity');
           console.log(isVisibleWithinViewport); // outputs: false
       });
    * </example>
    *
    * @alias browser.isVisibleWithinViewport
    * @param   {String}             selector  DOM-element
    * @return {Boolean|Boolean[]}            true if element(s)* [is|are] visible
    * @uses protocol/selectorExecute, protocol/timeoutsAsyncScript
    * @type state
    *
    */