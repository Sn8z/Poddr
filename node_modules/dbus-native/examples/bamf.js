const dbus = require('../index');

var bus = dbus.sessionBus();
var ayatana = bus.getService('org.ayatana.bamf');

bus.connection.on('message', console.log);

ayatana.getInterface(
  '/org/ayatana/bamf/matcher',
  'org.ayatana.bamf.matcher',
  function(err, bm) {
    console.log(err, bm);
    bm.on('ActiveWindowChanged', function(oldwin, newwin) {
      console.log('ActiveWindowChanged', oldwin, newwin);
    });
    bm.on('ActiveApplicationChanged', function(oldwin, newwin) {
      console.log('ActiveApplicationChanged', oldwin, newwin);
    });
  }
);
