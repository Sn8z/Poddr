#ifndef INTROSPECT_H_
#define INTROSPECT_H_

namespace Introspect {

	using namespace node;
	using namespace v8;
	using namespace std;

	typedef enum {
		INTROSPECT_NONE,
		INTROSPECT_ROOT,
		INTROSPECT_METHOD,
		INTROSPECT_PROPERTY,
		INTROSPECT_SIGNAL
	} IntrospectClass;

	typedef struct {
		Nan::Persistent<Object> obj;
		Nan::Persistent<Object> current_interface;
		Nan::Persistent<Object> current_method;
		Nan::Persistent<Array> current_signal;
		IntrospectClass current_class;
	} IntrospectObject;

	Local<Value> CreateObject(const char *source);
}

#endif
