#include <v8.h>
#include <node.h>
#include <string>
#include <dbus/dbus.h>
#include <nan.h>

#include "decoder.h"

namespace Decoder {

	using namespace node;
	using namespace v8;
	using namespace std;

	Local<Value> DecodeMessageIter(DBusMessageIter *iter, const char *signature)
	{
		Nan::EscapableHandleScope scope;
		DBusSignatureIter siter;
		int cur_type = dbus_message_iter_get_arg_type(iter);

		// Trying to use signature to handle this iterator if type cannot be recognized
		if (cur_type == DBUS_TYPE_INVALID) {
			dbus_signature_iter_init(&siter, signature);
			cur_type = dbus_signature_iter_get_current_type(&siter);
		}

		// Get type of current value
		switch(cur_type) {
#define DBUS_BASIC_TYPE(arg_type, dbus_type, def_val, v8_type) \
		case arg_type: \
		{ \
			dbus_type value = def_val; \
			dbus_message_iter_get_basic(iter, &value); \
			return scope.Escape(Nan::New<v8_type>(value)); \
		}
		DBUS_BASIC_TYPE(DBUS_TYPE_BOOLEAN, dbus_bool_t, false, Boolean)
		DBUS_BASIC_TYPE(DBUS_TYPE_BYTE, unsigned char, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_INT16, dbus_int16_t, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_UINT16, dbus_uint16_t, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_INT32, dbus_int32_t, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_UINT32, dbus_uint32_t, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_INT64, dbus_int64_t, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_UINT64, dbus_uint64_t, 0, Number)
		DBUS_BASIC_TYPE(DBUS_TYPE_DOUBLE, double, 0, Number)
#undef DBUS_BASIC_TYPE

		case DBUS_TYPE_OBJECT_PATH:
		case DBUS_TYPE_SIGNATURE:
		case DBUS_TYPE_STRING:
		{
			const char *value;
			dbus_message_iter_get_basic(iter, &value); 
			return scope.Escape(Nan::New<String>(value).ToLocalChecked());
		}

		case DBUS_TYPE_STRUCT:
		{
			char *sig = NULL;

			// Create a object
			Local<Object> result = Nan::New<Object>();

			do {
				// Getting sub iterator
				DBusMessageIter dict_entry_iter;
				dbus_message_iter_recurse(iter, &dict_entry_iter);

				// Getting key
				sig = dbus_message_iter_get_signature(&dict_entry_iter);
				Local<Value> key = DecodeMessageIter(&dict_entry_iter, sig);
				dbus_free(sig);
				if (key->IsUndefined())
					continue;

				// Try to get next element
				Local<Value> value;
				if (dbus_message_iter_next(&dict_entry_iter)) {
					// Getting value
					sig = dbus_message_iter_get_signature(&dict_entry_iter);
					value = DecodeMessageIter(&dict_entry_iter, sig);
					dbus_free(sig);
				} else {
					value = Nan::Undefined();
				}

				// Append a property
				result->Set(key, value); 

			} while(dbus_message_iter_next(iter));

			return scope.Escape(result);
		}

		case DBUS_TYPE_ARRAY:
		{
			bool is_dict = false;
			char *sig = NULL;
			DBusMessageIter internal_iter;

			// Initializing signature
			dbus_signature_iter_init(&siter, signature);
			dbus_message_iter_recurse(iter, &internal_iter);

			if (dbus_message_iter_get_arg_type(&internal_iter) == DBUS_TYPE_DICT_ENTRY) {
				is_dict = true;
			} else if (dbus_message_iter_get_element_type(iter) == DBUS_TYPE_DICT_ENTRY) {
				is_dict = true;
			} else if (dbus_message_iter_get_arg_type(iter) == DBUS_TYPE_ARRAY &&
				dbus_signature_iter_get_current_type(&siter) == DBUS_TYPE_ARRAY) {

				if (dbus_signature_iter_get_element_type(&siter) == DBUS_TYPE_DICT_ENTRY)
					is_dict = true;
			}

			// It's dictionary
			if (is_dict) {

				// Create a object
				Local<Object> result = Nan::New<Object>();

				// Make sure it doesn't empty
				if (dbus_message_iter_get_arg_type(&internal_iter) == DBUS_TYPE_INVALID)
					return scope.Escape(result);

				do {
					// Getting sub iterator
					DBusMessageIter dict_entry_iter;
					dbus_message_iter_recurse(&internal_iter, &dict_entry_iter);

					// Getting key
					sig = dbus_message_iter_get_signature(&dict_entry_iter);
					Local<Value> key = DecodeMessageIter(&dict_entry_iter, sig);
					dbus_free(sig);
					if (key->IsUndefined())
						continue;

					// Try to get next element
					Local<Value> value;
					if (dbus_message_iter_next(&dict_entry_iter)) {
						// Getting value
						sig = dbus_message_iter_get_signature(&dict_entry_iter);
						value = DecodeMessageIter(&dict_entry_iter, sig);
						dbus_free(sig);
					} else {
						value = Nan::Undefined();
					}

					// Append a property
					result->Set(key, value); 

				} while(dbus_message_iter_next(&internal_iter));

				return scope.Escape(result);
			}

			// Create an array
			unsigned int count = 0;
			Local<Array> result = Nan::New<Array>();
			if (dbus_message_iter_get_arg_type(&internal_iter) == DBUS_TYPE_INVALID)
				return scope.Escape(result);

			do {

				// Getting element
				sig = dbus_message_iter_get_signature(&internal_iter);
				Local<Value> value = DecodeMessageIter(&internal_iter, sig);
				dbus_free(sig);
				if (value->IsUndefined())
					continue;

				// Append item
				result->Set(count, value);

				count++;
			} while(dbus_message_iter_next(&internal_iter));

			return scope.Escape(result);
		}

		case DBUS_TYPE_VARIANT:
		{
			char *sig = NULL;
			DBusMessageIter internal_iter;
			dbus_message_iter_recurse(iter, &internal_iter);

			sig = dbus_message_iter_get_signature(&internal_iter);
			Local<Value> value = DecodeMessageIter(&internal_iter, sig);
			dbus_free(sig);

			return scope.Escape(value);
		}

		default:
			return Nan::Undefined();

		}

		return Nan::Undefined();
	}

	Local<Value> DecodeMessage(DBusMessage *message)
	{
		Nan::EscapableHandleScope scope;
		DBusMessageIter iter;

		if (!dbus_message_iter_init(message, &iter))
			return Nan::Undefined();

		if (dbus_message_get_type(message) == DBUS_MESSAGE_TYPE_ERROR)
			return Nan::Undefined();

		if (dbus_message_iter_get_arg_type(&iter) == DBUS_TYPE_INVALID)
			return Nan::Undefined();

		Local<Array> result = Nan::New<Array>();
		unsigned int count = 0;
		char *signature = NULL;
		Local<Value> value;

		do {
			signature = dbus_message_iter_get_signature(&iter);
			value = DecodeMessageIter(&iter, signature);
			dbus_free(signature);
			if (value->IsUndefined())
				continue;

			result->Set(count, value);

			count++;
		} while(dbus_message_iter_next(&iter));

		if (count == 1) {
			return scope.Escape(value);
		}

		return scope.Escape(result);
	}

	Local<Value> DecodeArguments(DBusMessage *message)
	{
		Nan::EscapableHandleScope scope;
		DBusMessageIter iter;
		Local<Array> result = Nan::New<Array>();

		if (!dbus_message_iter_init(message, &iter))
			return scope.Escape(result);

		if (dbus_message_get_type(message) == DBUS_MESSAGE_TYPE_ERROR)
			return scope.Escape(result);

		// No argument
		if (dbus_message_iter_get_arg_type(&iter) == DBUS_TYPE_INVALID)
			return scope.Escape(result);

		unsigned int count = 0;
		char *signature = NULL;

		do {
			signature = dbus_message_iter_get_signature(&iter);
			Local<Value> value = DecodeMessageIter(&iter, signature);
			dbus_free(signature);
			if (value->IsUndefined())
				continue;

			result->Set(count, value);

			count++;
		} while(dbus_message_iter_next(&iter));

		return scope.Escape(result);
	}
}

