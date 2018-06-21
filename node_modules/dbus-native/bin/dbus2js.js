#!/usr/bin/env node

const fs = require('fs');
const xml2js = require('xml2js');
const dbus = require('../index');
const optimist = require('optimist');

var argv = optimist.boolean(['server', 'dump']).argv;

function die(err) {
  console.log(err);
  process.exit(-1);
}

var bus = argv.bus === 'system' ? dbus.systemBus() : dbus.sessionBus();

function getXML(callback) {
  if (argv.xml) {
    fs.readFile(argv.xml, 'ascii', callback);
  } else {
    bus.invoke(
      {
        destination: argv.service,
        path: argv.path,
        interface: 'org.freedesktop.DBus.Introspectable',
        member: 'Introspect'
      },
      callback
    );
  }
}

if (argv.dump) {
  getXML(function(err, xml) {
    console.log(xml);
    bus.connection.end();
  });
}

if (!argv.server) {
  getXML(function(err, xml) {
    if (err) die(err);

    var output = [];

    var parser = new xml2js.Parser({ explicitArray: true });
    parser.parseString(xml, function(err, result) {
      if (err) die(err);

      var ifaceName, method, property, iface, arg, signature;
      var ifaces = result['interface'];
      for (var i = 0; i < ifaces.length; ++i) {
        iface = ifaces[i];
        ifaceName = iface['@'].name;

        output.push(`module.exports['${ifaceName}'] = function(bus) {`);
        output.push(
          '    this.addListener = this.on = function(signame, callback) {'
        );
        //TODO: add path and interface to path
        output.push(
          "        bus.addMatch('type=\\'signal\\',member=\\'' + signame + '\\'', function(err, result) {"
        );
        output.push('            if (err) throw new Error(err);');
        output.push('        });');
        output.push(
          `        var signalFullName = bus.mangle('${argv.path}', '${
            ifaceName
          }', signame);`
        );
        output.push(
          '        bus.signals.on(signalFullName, function(messageBody) {'
        );
        output.push('             callback.apply(null, messageBody);');
        output.push('        });');
        output.push('    };');

        for (var m = 0; iface.method && m < iface.method.length; ++m) {
          method = iface.method[m];
          signature = '';
          const methodName = method['@'].name;

          var decl = `    this.${methodName} = function(`;
          var params = [];
          for (var a = 0; method.arg && a < method.arg.length; ++a) {
            arg = method.arg[a]['@'];
            if (arg.direction === 'in') {
              decl += `${arg.name}, `;
              params.push(arg.name);
              signature += arg.type;
            }
          }
          decl += 'callback) {';
          output.push(decl);
          output.push('        bus.invoke({');
          output.push(`            destination: '${argv.service}',`);
          output.push(`            path: '${argv.path}',`);
          output.push(`            interface: '${ifaceName}',`);
          output.push(`            member: '${methodName}',`);
          if (params.length > 0) {
            output.push(`            body: [${params.join(', ')}], `);
            output.push(`            signature: '${signature}',`);
          }
          output.push('        }, callback);');
          output.push('    };');
        }
        for (var p = 0; iface.property && p < iface.property.length; ++p) {
          property = iface.property[p];
          console.log('    property: \n', property);
        }
        output.push('}');
      }
      console.log(output.join('\n'));
      bus.connection.end();
    });
  });
}
