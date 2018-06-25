#ifndef ENCODER_H_
#define ENCODER_H_

namespace Encoder {

	using namespace node;
	using namespace v8;
	using namespace std;

	string GetSignatureFromV8Type(Local<Value>& value);
	
	// expects two signatures - one for the type signature as DBus will see it,
	// and a second that is the same as the first, except that variants requiring
	// a particular concrete type inside should be replaced by their required concrete type.
	// 
	// for example, when writing a property, the property value in the Get method is
	// a variant at the DBus interface level, but should only actually be encoded with
	// the actual concrete type declared for the property.
	//
	// If the concrete type is NULL or the same as the main one, types of variant
	// elements will be inferred based on the V8 type (and, in the case of numbers,
	// their values)
	bool EncodeObject(Local<Value> value, DBusMessageIter *iter,
		const DBusSignatureIter *siter, const DBusSignatureIter *concreteSiter = NULL);
}

#endif
