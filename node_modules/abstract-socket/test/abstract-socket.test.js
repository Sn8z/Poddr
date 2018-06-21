'use strict';

const spawn = require('child_process').spawn;
const should = require('should'); // jshint ignore: line
const abs = require('../lib/abstract_socket.js');

const SOCKET_NAME = '\0test312';
const SOME_DATA = 'asdqq\n';

describe('server', function() {
    describe('listening', function() {
        let server;
        beforeEach(() => (server = abs.createServer()) && server.listen(SOCKET_NAME));
        afterEach(() => server.close());

        it('should listen on abstract socket', () => exec('lsof -U')
            .then(output => output.should.containEql(`@${SOCKET_NAME.slice(1)}`)));

        it('should emit error when socket is busy', done => {
            const server = abs.createServer();
            server.listen(SOCKET_NAME);
            server.on('error', err => {
                err.syscall.should.equal('listen');
                done();
            });
        });

        it('should stop listening when close is called', () => new Promise(resolve => {
            server.close(resolve);
        })
            .then(() => exec('lsof -U'))
            .then(output => output.should.not.containEql(`@${SOCKET_NAME.slice(1)}`)));
    });

    describe('client connections', function() {
        let server;
        beforeEach(() => (server = abs.createServer()) && server.listen(SOCKET_NAME));
        afterEach(() => server.close());

        it('should emit event when client connects', done => {
            server.on('connection', () => done());
            abs.connect(SOCKET_NAME);
        });

        it('should receive client data', done => {
            server.on('connection', client => {
                client.on('data', data => {
                    data.toString().should.equal(SOME_DATA);
                    done();
                });
            });
            abs.connect(SOCKET_NAME).write(SOME_DATA);
        });
    });

    describe('messages', function() {
        let server;
        beforeEach(() => (server = abs.createServer()) && server.listen(SOCKET_NAME));
        afterEach(() => server.close());

        it('should be received from the client', done => {
            server.on('connection', client => {
                client.on('data', data => {
                    data.toString().should.equal(SOME_DATA);
                    done();
                });
            });
            const client = abs.connect(SOCKET_NAME, () => {
                client.write(SOME_DATA);
            });
        });

        it('should be sent from the server', done => {
            server.on('connection', client => {
                client.end(SOME_DATA);
            });
            const client = abs.connect(SOCKET_NAME);
            client.on('data', data => {
                data.toString().should.equal(SOME_DATA);
                done();
            });
        });

        it('should be able to send large data', done => {
            const LENGTH = 65537;
            const FILL_CHAR = 't';
            const buf = new Buffer(LENGTH);
            buf.fill(FILL_CHAR);
            server.on('connection', client => {
                client.end(buf);
            });
            const client = abs.connect(SOCKET_NAME);
            let res = new Buffer(0);
            client.on('data', data => {
                res = Buffer.concat([res, data], res.length + data.length);
            });
            client.on('end', () => {
                res.length.should.equal(LENGTH);
                res.toString().split('').forEach(t => t.should.equal(FILL_CHAR));
                done();
            });
        });
    });
});

describe('client', function() {
    describe('should emit error', function() {
        it('when connecting to a non existent socket', done => {
            abs.connect('\0non-existent-socket').on('error', () => done());
        });

        it('when connecting to a non abstract socket', done => {
            abs.connect('non-abstract-socket').on('error', () => done());
        });
    });

    describe('connect callback', function() {
        let server;
        beforeEach(() => (server = abs.createServer()) && server.listen(SOCKET_NAME));
        afterEach(() => server.close());

        it('should be called when connected', done => {
            abs.connect(SOCKET_NAME, () => done());
        });

        it('should be called asynchronously', done => {
            let counter = 0;
            abs.connect(SOCKET_NAME, () => {
                counter.should.equal(1);
                done();
            });
            ++counter;
        });
    });

    describe('messages', function() {
        let server;
        beforeEach(() => (server = abs.createServer()) && server.listen(SOCKET_NAME));
        afterEach(() => server.close());

        it('should be sent to the server', done => {
            server.on('connection', client => {
                client.on('data', data => {
                    data.toString().should.equal(SOME_DATA);
                    done();
                });
            });
            const client = abs.connect(SOCKET_NAME, () => {
                client.write(SOME_DATA);
            });
        });

        it('should be able to send large data', done => {
            const LENGTH = 65537;
            const FILL_CHAR = 't';
            const buf = new Buffer(LENGTH);
            buf.fill(FILL_CHAR);
            server.on('connection', client => {
                let res = new Buffer(0);
                client.on('data', data => {
                    res = Buffer.concat([res, data], res.length + data.length);
                    if (res.length < LENGTH) {
                        return;
                    }
                    res.length.should.equal(LENGTH);
                    res.toString().split('').forEach(t => t.should.equal(FILL_CHAR));
                    done();
                });
            });
            const client = abs.connect(SOCKET_NAME, () => {
                client.end(buf);
            });
        });

        it('should be received from the server', done => {
            server.on('connection', client => {
                client.end(SOME_DATA);
            });
            const client = abs.connect(SOCKET_NAME);
            client.on('data', data => {
                data.toString().should.equal(SOME_DATA);
                done();
            });
        });
    });
});

function exec(cmd, options) {
    return new Promise((resolve, reject) => {
        let bin = cmd.split(' ').shift();
        let params = cmd.split(' ').slice(1);
        let child = spawn(bin, params, options);
        let res = new Buffer(0);
        let err = new Buffer(0);

        child.stdout.on('data', buf => res = Buffer.concat([res, buf], res.length + buf.length));
        child.stderr.on('data', buf => err = Buffer.concat([err, buf], err.length + buf.length));
        child.on('close', code => {
            return setImmediate(() => {
                // setImmediate is required because there are often still
                // pending write requests in both stdout and stderr at this point
                if (code) {
                    reject(err.toString());
                } else {
                    resolve(res.toString());
                }
            });
        });
        child.on('error', reject);
    });
}

