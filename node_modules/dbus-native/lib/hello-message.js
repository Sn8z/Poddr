const Buffer = require('safe-buffer').Buffer;

// Pre-serialised hello message. serial = 1
module.exports = function() {
  return Buffer.from(
    `6c01 0001 0000 0000 0100 0000 6d00 0000
     0101 6f00 1500 0000 2f6f 7267 2f66 7265
     6564 6573 6b74 6f70 2f44 4275 7300 0000
     0301 7300 0500 0000 4865 6c6c 6f00 0000
     0201 7300 1400 0000 6f72 672e 6672 6565
     6465 736b 746f 702e 4442 7573 0000 0000
     0601 7300 1400 0000 6f72 672e 6672 6565
     6465 736b 746f 702e 4442 7573 0000 0000`.replace(/ |\n/g, ''),
    'hex'
  );
};
