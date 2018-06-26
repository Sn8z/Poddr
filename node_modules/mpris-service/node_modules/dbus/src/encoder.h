#ifndef ENCODER_H_
#define ENCODER_H_

namespace Encoder {

	using namespace node;
	using namespace v8;
	using namespace std;

	string GetSignatureFromV8Type(Local<Value>& value);
	bool EncodeObject(Local<Value> value, DBusMessageIter *iter, const char *signature);
}

#endif
