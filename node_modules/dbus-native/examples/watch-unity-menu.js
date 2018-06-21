const dbus = require('../index');

var bus = dbus.sessionBus();
var panel = bus.getService('com.canonical.Unity.Panel.Service');
panel.getInterface(
  '/com/canonical/Unity/Panel/Service',
  'com.canonical.Unity.Panel.Service',
  function(err, nm) {
    nm.addListener('EntryActivated', function(entry) {
      console.log(entry);
    });
  }
);
