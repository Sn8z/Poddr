'use strict';
const utils = require('../utils');

module.exports = function fcopy_sendfile(binding) {
    return utils.withFileDescriptors(binding.sendfile);
};
