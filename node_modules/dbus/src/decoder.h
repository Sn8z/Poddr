#ifndef DECODER_H_
#define DECODER_H_

namespace Decoder {

	using namespace node;
	using namespace v8;
	using namespace std;

	Local<Value> DecodeMessage(DBusMessage *message);
	Local<Value> DecodeArguments(DBusMessage *message);
}

#endif
