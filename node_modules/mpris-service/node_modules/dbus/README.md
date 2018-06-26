# node-dbus  
node-dbus is a D-Bus binding for Node.js.

[![Build Status](https://travis-ci.org/Shouqun/node-dbus.svg?branch=master)](https://travis-ci.org/Shouqun/node-dbus)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](#license)

## Installation

```bash
$ npm install dbus
```

## How To Build
To build, do: `node-gyp configure build` or `npm install`.

## Dependencies

### General

**Node-gyp**  
`$ npm install -g node-gyp`  
[https://www.npmjs.com/package/node-gyp](https://www.npmjs.com/package/node-gyp)

**libdbus**  
`$ sudo apt-get install libdbus-1-dev`  
or equivalent for your system

**glib2.0**  
`$ sudo apt-get install libglib2.0-dev`  
or equivalent for your system

### MacOS with MacPorts/HomeBrew

**Node-gyp**  
`$ npm install -g node-gyp`  
[https://www.npmjs.com/package/node-gyp](https://www.npmjs.com/package/node-gyp)

**libdbus**  
MacPorts: `$ sudo port install pkg-config dbus`
HomeBrew: `$ sudo brew install pkg-config dbus`

**glib2.0**  
MacPorts: `$ sudo port install glib2`
HomeBrew: `$ sudo brew install glib`

## Getting Started
Best way to get started is by looking at the examples. After the build:

1. Navigate to `path/to/dbus/examples` folder
1. Run `node service.js &`
1. Run  `node hello.js`

Work your way through other examples to explore supported functionality.

## Note on systems without X11
If no X server is running, the module fails when attempting to obtain a D-Bus
connection at `dbus._dbus.getBus()`. This can be remedied by setting two
environment variables manually (the actual bus address might be different):

	process.env.DISPLAY = ':0';
	process.env.DBUS_SESSION_BUS_ADDRESS = 'unix:path=/run/dbus/system_bus_socket';

## License 

(The MIT License)

Copyright (c) 2013

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

