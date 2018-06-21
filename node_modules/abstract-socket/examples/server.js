'use strict';

require('../lib/abstract_socket.js')
    .createServer(client => {
        console.log('client connected');
        client.on('end', () => {
            console.log('client disconnected');
        })
            .pipe(client)
            .write('hello from server\r\n');
    })
    .on('error', err => {
        console.log('server error', err);
    })
    .listen('\0foo2');

