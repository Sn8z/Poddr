'use strict';

const client = require('../lib/abstract_socket.js')
    .connect('\0foo2', () => { //'connect' listener
        console.log('client connected');
    })
    .on('data', data => {
        console.log(data.toString());
    })
    .on('error', err => {
        console.log('caught', err);
    })
    .on('end', () => {
        console.log('client ended');
    });

process.stdin.setEncoding('utf8')
    .on('readable', () => {
        const chunk = process.stdin.read();
        if (chunk !== null)
            client.write(chunk);
    });

