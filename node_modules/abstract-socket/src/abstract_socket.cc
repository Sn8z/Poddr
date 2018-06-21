// -D_GNU_SOURCE makes SOCK_NONBLOCK etc. available on linux
#undef  _GNU_SOURCE
#define _GNU_SOURCE

#if !defined(__linux__)
# error "Only Linux is supported"
#endif

#include <nan.h>

#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>


namespace {

using v8::FunctionTemplate;
using v8::Local;
using v8::Object;
using v8::String;
using v8::Value;


#if !defined(SOCK_NONBLOCK)
void SetNonBlock(int fd) {
    int flags;
    int r;

    flags = fcntl(fd, F_GETFL);
    assert(flags != -1);

    r = fcntl(fd, F_SETFL, flags | O_NONBLOCK);
    assert(r != -1);
}
#endif


#if !defined(SOCK_CLOEXEC)
void SetCloExec(int fd) {
    int flags;
    int r;

    flags = fcntl(fd, F_GETFD);
    assert(flags != -1);

    r = fcntl(fd, F_SETFD, flags | FD_CLOEXEC);
    assert(r != -1);
}
#endif


NAN_METHOD(Socket) {
    Nan::HandleScope scope;
    int fd;
    int type;

    assert(info.Length() == 0);

    type = SOCK_STREAM;
#if defined(SOCK_NONBLOCK)
    type |= SOCK_NONBLOCK;
#endif
#if defined(SOCK_CLOEXEC)
    type |= SOCK_CLOEXEC;
#endif

    fd = socket(AF_UNIX, type, 0);
    if (fd == -1) {
        fd = -errno;
        goto out;
    }

#if !defined(SOCK_NONBLOCK)
    SetNonBlock(fd);
#endif
#if !defined(SOCK_CLOEXEC)
    SetCloExec(fd);
#endif

out:
    info.GetReturnValue().Set(fd);
}


NAN_METHOD(Bind) {
    Nan::HandleScope scope;
    sockaddr_un s;
    socklen_t namelen;
    int err;
    int fd;
    unsigned int len;

    assert(info.Length() == 2);

    fd = info[0]->Int32Value();
    String::Utf8Value path(info[1]);

    if ((*path)[0] != '\0') {
        err = -EINVAL;
        goto out;
    }

    len = path.length();
    if (len > sizeof(s.sun_path)) {
        err = -EINVAL;
        goto out;
    }

    memset(&s, 0, sizeof s);
    memcpy(s.sun_path, *path, len);
    s.sun_family = AF_UNIX;
    namelen = offsetof(struct sockaddr_un, sun_path) + len;

    err = 0;
    if (bind(fd, reinterpret_cast<sockaddr*>(&s), namelen))
        err = -errno;

out:
    info.GetReturnValue().Set(err);
}


NAN_METHOD(Connect) {
    Nan::HandleScope scope;
    sockaddr_un s;
    socklen_t namelen;
    int err;
    int fd;
    unsigned int len;

    assert(info.Length() == 2);

    fd = info[0]->Int32Value();
    String::Utf8Value path(info[1]);

    if ((*path)[0] != '\0') {
        err = -EINVAL;
        goto out;
    }

    len = path.length();
    if (len > sizeof(s.sun_path)) {
        err = -EINVAL;
        goto out;
    }

    memset(&s, 0, sizeof s);
    memcpy(s.sun_path, *path, len);
    s.sun_family = AF_UNIX;
    namelen = offsetof(struct sockaddr_un, sun_path) + len;

    err = 0;
    if (connect(fd, reinterpret_cast<sockaddr*>(&s), namelen))
        err = -errno;

out:
    info.GetReturnValue().Set(err);
}


NAN_METHOD(Close) {
    Nan::HandleScope scope;
    int err;
    int fd;

    assert(info.Length() == 1);
    fd = info[0]->Int32Value();

    // Suppress EINTR and EINPROGRESS.  EINTR means that the close() system call
    // was interrupted by a signal.  According to POSIX, the file descriptor is
    // in an undefined state afterwards.  It's not safe to try closing it again
    // because it may have been closed, despite the signal.  If we call close()
    // again, then it would either:
    //
    //   a) fail with EBADF, or
    //
    //   b) close the wrong file descriptor if another thread or a signal handler
    //      has reused it in the mean time.
    //
    // Neither is what we want but scenario B is particularly bad.  Not retrying
    // the close() could, in theory, lead to file descriptor leaks but, in
    // practice, operating systems do the right thing and close the file
    // descriptor, regardless of whether the operation was interrupted by
    // a signal.
    //
    // EINPROGRESS is benign.  It means the close operation was interrupted but
    // that the file descriptor has been closed or is being closed in the
    // background.  It's informative, not an error.
    err = 0;
    if (close(fd))
      if (errno != EINTR && errno != EINPROGRESS)
        err = -errno;

    info.GetReturnValue().Set(err);
}


void Initialize(Local<Object> target) {
    target->Set(Nan::New("socket").ToLocalChecked(),
                Nan::New<FunctionTemplate>(Socket)->GetFunction());
    target->Set(Nan::New("bind").ToLocalChecked(),
                Nan::New<FunctionTemplate>(Bind)->GetFunction());
    target->Set(Nan::New("connect").ToLocalChecked(),
                Nan::New<FunctionTemplate>(Connect)->GetFunction());
    target->Set(Nan::New("close").ToLocalChecked(),
                Nan::New<FunctionTemplate>(Close)->GetFunction());
}


} // anonymous namespace

NODE_MODULE(abstract_socket, Initialize)
