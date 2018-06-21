
import socket
import sys


client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
client.connect('\x00foo')

try:
    while True:
        data = sys.stdin.readline()
        client.send(data)
        data = client.recv(1024)
        if not data:
            break
        print 'Received data: %s' % data
except KeyboardInterrupt:
    client.close()

