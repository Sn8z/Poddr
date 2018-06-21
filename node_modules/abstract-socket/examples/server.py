
import socket
import thread


def handle_connection(sock, addr):
    print 'Incoming connection %r' % sock
    while True:
        data = sock.recv(1024)
        if not data:
            print 'Connection closed'
            break
        sock.send(data)


server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
print 'FD: %d' % server.fileno()
server.bind('\x00foo')
server.listen(128)

while True:
    sock, addr = server.accept()
    thread.start_new_thread(handle_connection, (sock, addr))

