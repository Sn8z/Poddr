const dbus = require('../index');

var bus = dbus.sessionBus();
var notify = bus.getService('org.freedesktop.Notifications');
notify.getInterface(
  '/org/freedesktop/Notifications',
  'org.freedesktop.Notifications',
  function(err, nm) {
    console.log(nm);
    nm.on('ActionInvoked', function() {
      console.log('ActionInvoked', arguments);
    });
    nm.on('NotificationClosed', function() {
      console.log('NotificationClosed', arguments);
    });
    nm.Notify(
      'exampl',
      0,
      '',
      'summary 3',
      'new message text',
      ['xxx yyy', 'test2', 'test3', 'test4'],
      [],
      5,
      function(err /*, id*/) {
        console.log(err);
        //setTimeout(function() { n.CloseNotification(id, console.log); }, 4000);
      }
    );
  }
);
