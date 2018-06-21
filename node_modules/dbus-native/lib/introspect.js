const xml2js = require('xml2js');

module.exports = function(obj, callback) {
  var bus = obj.service.bus;
  bus.invoke(
    {
      destination: obj.service.name,
      path: obj.name,
      interface: 'org.freedesktop.DBus.Introspectable',
      member: 'Introspect'
    },
    function(err, xml) {
      if (err) return callback(err);
      var parser = new xml2js.Parser({ explicitArray: true });
      parser.parseString(xml, function(err, result) {
        if (err) return callback(err);
        if (!result.interface) {
          if (result.node && result.node.length > 0 && result.node[0]['@']) {
            var subObj = Object.assign(obj, {});
            if (subObj.name.slice(-1) !== '/') subObj.name += '/';
            subObj.name += result.node[0]['@'].name;
            return module.exports(subObj, callback);
          }
          return callback(new Error('No such interface found'));
        }
        var proxy = {};
        var nodes = [];
        var ifaceName, method, property, iface, arg, signature, currentIface;
        var ifaces = result['interface'];
        var xmlnodes = result['node'] || [];

        for (var n = 1; n < xmlnodes.length; ++n) {
          // Start at 1 because we want to skip the root node
          nodes.push(xmlnodes[n]['@']['name']);
        }

        for (var i = 0; i < ifaces.length; ++i) {
          iface = ifaces[i];
          ifaceName = iface['@'].name;
          currentIface = proxy[ifaceName] = {};

          (function() {
            var callbacks = [];
            var sigHandlers = [];
            function getSigHandler(callback) {
              var index;
              if ((index = callbacks.indexOf(callback)) === -1) {
                index = callbacks.push(callback) - 1;
                sigHandlers[index] = function(messageBody) {
                  callback.apply(null, messageBody);
                };
              }
              return sigHandlers[index];
            }

            function getMatchRule(objName, ifName, signame) {
              return `type='signal',path='${objName}',interface='${
                ifName
              }',member='${signame}'`;
            }

            currentIface.addListener = currentIface.on = (function(ifName) {
              return function(signame, callback) {
                // http://dbus.freedesktop.org/doc/api/html/group__DBusBus.html#ga4eb6401ba014da3dbe3dc4e2a8e5b3ef
                // An example is "type='signal',sender='org.freedesktop.DBus', interface='org.freedesktop.DBus',member='Foo', path='/bar/foo',destination=':452345.34'" ...

                var signalFullName = bus.mangle(obj.name, ifName, signame);

                if (!bus.signals.listeners(signalFullName).length) {
                  // This is the first time, so call addMatch
                  var match = getMatchRule(obj.name, ifName, signame);
                  bus.addMatch(match, function(err) {
                    if (err) throw new Error(err);

                    bus.signals.on(signalFullName, getSigHandler(callback));
                  });
                } else {
                  // The match is already there, just add event listener
                  bus.signals.on(signalFullName, getSigHandler(callback));
                }
              };
            })(ifaceName);

            currentIface.removeListener = (function(ifName) {
              return function(signame, callback) {
                var signalFullName = bus.mangle(obj.name, ifName, signame);
                bus.signals.removeListener(
                  signalFullName,
                  getSigHandler(callback)
                );

                if (!bus.signals.listeners(signalFullName).length) {
                  // There is no event handlers for this match
                  var match = getMatchRule(obj.name, ifName, signame);
                  bus.removeMatch(match, function(err) {
                    if (err) throw new Error(err);

                    // Now it is safe to empty these arrays
                    callbacks.length = 0;
                    sigHandlers.length = 0;
                  });
                }
              };
            })(ifaceName);
          })();

          for (var m = 0; iface.method && m < iface.method.length; ++m) {
            method = iface.method[m];
            signature = '';
            var methodName = method['@'].name;
            for (var a = 0; method.arg && a < method.arg.length; ++a) {
              arg = method.arg[a]['@'];
              if (arg.direction === 'in') signature += arg.type;
            }

            // add method
            currentIface[methodName] = (function(ifName, mName, signature) {
              return function() {
                var args = Array.prototype.slice.apply(arguments);
                var callback =
                  typeof args[args.length - 1] === 'function'
                    ? args.pop()
                    : function() {};
                var msg = {
                  destination: obj.service.name,
                  path: obj.name,
                  interface: ifName,
                  member: mName
                };
                if (signature !== '') {
                  msg.signature = signature;
                  msg.body = args;
                }
                bus.invoke(msg, callback);
              };
            })(ifaceName, methodName, signature);
          }
          for (var p = 0; iface.property && p < iface.property.length; ++p) {
            property = iface.property[p];
            var propertyName = property['@'].name;
            //TODO: move up
            var addReadProp = function(iface, ifName, propName, property) {
              Object.defineProperty(iface, propName, {
                enumerable: true,
                get: function() {
                  return function(callback) {
                    bus.invoke(
                      {
                        destination: obj.service.name,
                        path: obj.name,
                        interface: 'org.freedesktop.DBus.Properties',
                        member: 'Get',
                        signature: 'ss',
                        body: [ifName, propName]
                      },
                      function(err, val) {
                        if (err) {
                          callback(err);
                        } else {
                          var signature = val[0];
                          if (signature.length === 1) {
                            callback(err, val[1][0]);
                          } else {
                            callback(err, val[1]);
                          }
                        }
                      }
                    );
                  };
                },
                set: function(val) {
                  bus.invoke({
                    destination: obj.service.name,
                    path: obj.name,
                    interface: 'org.freedesktop.DBus.Properties',
                    member: 'Set',
                    signature: 'ssv',
                    body: [ifName, propName, [property['@'].type, val]]
                  });
                }
              });
            };
            addReadProp(currentIface, ifaceName, propertyName, property);
          }
          // TODO: introspect signals
        }
        callback(null, proxy, nodes);
      });
    }
  );
};
