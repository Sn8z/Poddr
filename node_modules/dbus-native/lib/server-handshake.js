const Buffer = require('safe-buffer').Buffer;
const readLine = require('./readline');

module.exports = function serverHandshake(stream, opts, cb) {
  stream.name = 'SERVER SERVER';
  readLine(stream, function(hello) {
    console.log(['hello string: ', hello.toString(), hello]);
    stream.write('REJECTED EXTERNAL DBUS_COOKIE_SHA1 ANONYMOUS\r\n');
    readLine(stream, function() {
      stream.write(
        `DATA ${Buffer.from(
          'org_freedesktop_general 642038150 b9ce247a275f427c8586e4c9de9bb951'
        ).toString('hex')}\r\n`
      );
      readLine(stream, function() {
        stream.write(
          'OK 6f72675f667265656465736b746f705f67656e6572616c20353631303331333937206239636532343761323735663432376338353836653463396465396262393531\r\n'
        );
        readLine(stream, function(begin) {
          console.log(['AFTER begin: ', begin.toString()]);
          cb(null);
        });
      });
    });
  });
};

// cookie: 561031397 1410749774 3a83c8200f930e7af4de135e8abd299b681a1f44dbb85399

// 1539856202

// server: org_freedesktop_general 561031397 b9ce247a275f427c8586e4c9de9bb951
// client: bwFSDjS0TJerqb0l 82986a987194788803d7da2a4b00e801cff9bdfd
//                          82986a987194788803d7da2a4b00e801cff9bdfd = sha1(b9ce247a275f427c8586e4c9de9bb951:bwFSDjS0TJerqb0l:3a83c8200f930e7af4de135e8abd299b681a1f44dbb85399)
// server: OK e12a29dd7ffe3effac5eb95054123f80

//dbus.write('DATA 6f72675f667265656465736b746f705f67656e6572616c203636383430 31303032 203733653733313762383630356537323937623438303233376336353234343533\r\n');
