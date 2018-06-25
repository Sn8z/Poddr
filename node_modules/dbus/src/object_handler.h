#ifndef OBJECT_HANDLER_H_
#define OBJECT_HANDLER_H_

namespace ObjectHandler {

	using namespace node;
	using namespace v8;
	using namespace std;

	NAN_METHOD(RegisterObjectPath);
	NAN_METHOD(UnregisterObjectPath);
	NAN_METHOD(SendMessageReply);
	NAN_METHOD(SendErrorMessageReply);
	NAN_METHOD(SetObjectHandler);
}

#endif
