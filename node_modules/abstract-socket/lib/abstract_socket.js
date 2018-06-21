'use strict';

const net = require('net');
const binding = require('bindings')('abstract_socket.node');

const socket  = binding.socket;
const bind    = binding.bind;
const connect = binding.connect;
const close   = binding.close;


function errnoException(errorno, syscall) {
    // TODO: having the errno message here would be nice
    const e = new Error(syscall + ' ' + errorno);
    e.errno = e.code = errorno;
    e.syscall = syscall;
    return e;
}


class AbstractSocketServer extends net.Server {
    constructor(listener) {
        super(listener);
    }

    listen(name, listener) {
        let err = socket();
        if (err < 0) {
            this.emit(errnoException(err, 'socket'));
        }

        const handle = {fd: err};

        err = bind(err, name);
        if (err < 0) {
            close(handle.fd);
            this.emit(errnoException(err, 'bind'));
        }
        super.listen(handle, listener);
    }
}


exports.createServer = function(listener) {
    return new AbstractSocketServer(listener);
};


exports.connect = exports.createConnection = function(name, connectListener) {
    const defaultOptions = {
        readable: true,
        writable: true
    };

    let err = socket();
    if (err < 0) {
        const sock = new net.Socket(defaultOptions);
        setImmediate(() => sock.emit('error', errnoException(err, 'socket')));
        return sock;
    }

    const options = Object.assign({fd: err}, defaultOptions);

    // yes, connect is synchronous, so sue me
    err = connect(err, name);
    if (err < 0) {
        close(options.fd);
        const sock = new net.Socket(defaultOptions);
        setImmediate(() => sock.emit('error', errnoException(err, 'connect')));
        return sock;
    }

    const sock = new net.Socket(options);
    if (typeof connectListener === 'function') {
        setImmediate(() => connectListener(sock));
    }
    return sock;
};

