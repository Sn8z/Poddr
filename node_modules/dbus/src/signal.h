#ifndef SIGNAL_H_
#define SIGNAL_H_

namespace Signal {

	using namespace node;
	using namespace v8;
	using namespace std;

	void DispatchSignal(Local<Value> info[]);
	NAN_METHOD(EmitSignal);
	NAN_METHOD(SetSignalHandler);
}

#endif
