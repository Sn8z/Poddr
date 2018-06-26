#include <v8.h>
#include <node.h>
#include <cstring>
#include <stdlib.h>
#include <dbus/dbus.h>
#include <iostream>
#include <nan.h>

#include "encoder.h"

namespace Encoder {

	using namespace node;
	using namespace v8;
	using namespace std;

	bool IsByte(Local<Value>& value, const char* sig = NULL)
	{
		if(value->IsUint32()) {
			int number = value->Int32Value();
			if(number >= 0 && number <= 255) {
				return true;
			}
		}
		return false;
	}

	bool IsBoolean(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsTrue() || value->IsFalse() || value->IsBoolean();
	}

	bool IsUint32(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsUint32();
	}

	bool IsInt32(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsInt32();
	}

	bool IsNumber(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsNumber();
	}

	bool IsString(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsString();
	}

	bool IsArray(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsArray();
	}

	bool IsObject(Local<Value>& value, const char* sig = NULL)
	{
		return value->IsObject();
	}

	bool HasSameSig(Local<Value>& value, const char* sig = NULL)
	{
		return (sig) && (strlen(sig)) &&
			(0 == GetSignatureFromV8Type(value).compare(sig));
	}

typedef bool (*CheckTypeCallback) (Local<Value>& value, const char* sig);
	bool CheckArrayItems(Local<Array>& array, CheckTypeCallback checkType, const char* sig = NULL)
	{
		for (unsigned int i = 0; i < array->Length(); ++i) {
			Local<Value> arrayItem = array->Get(i);
			if (!checkType(arrayItem, sig))
				return false;
		}
		return true;
	}

	string GetSignatureFromV8Type(Local<Value>& value)
	{
		if (IsBoolean(value)) {
			return const_cast<char*>(DBUS_TYPE_BOOLEAN_AS_STRING);
		}
		if (IsByte(value)) {
			return const_cast<char*>(DBUS_TYPE_BYTE_AS_STRING);
		}
		if (IsUint32(value)) {
			return const_cast<char*>(DBUS_TYPE_UINT32_AS_STRING);
		}
		if (IsInt32(value)) {
			return const_cast<char*>(DBUS_TYPE_INT32_AS_STRING);
		}
		if (IsNumber(value)) {
			return const_cast<char*>(DBUS_TYPE_DOUBLE_AS_STRING);
		}
		if (IsString(value)) {
			return const_cast<char*>(DBUS_TYPE_STRING_AS_STRING);
		}
		if (IsArray(value)) {

			Local<Array> arrayData = Local<Array>::Cast(value);
			size_t arrayDataLength = arrayData->Length();

			if (0 == arrayDataLength) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_VARIANT_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsBoolean)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_BOOLEAN_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsByte)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_BYTE_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsUint32)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_UINT32_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsInt32)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_INT32_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsNumber)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_DOUBLE_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsString)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_STRING_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsArray)) {

				Local<Value> lastArrayItem = arrayData->Get(arrayDataLength - 1);
				string lastArrayItemSig = GetSignatureFromV8Type(lastArrayItem);

				if (CheckArrayItems(arrayData, HasSameSig, lastArrayItemSig.c_str())) {
					return string(const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING)).append(lastArrayItemSig);
				}
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_ARRAY_AS_STRING
					DBUS_TYPE_VARIANT_AS_STRING);
			}
			if (CheckArrayItems(arrayData, IsObject)) {
				return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_ARRAY_AS_STRING
					DBUS_DICT_ENTRY_BEGIN_CHAR_AS_STRING
					DBUS_TYPE_STRING_AS_STRING DBUS_TYPE_VARIANT_AS_STRING
					DBUS_DICT_ENTRY_END_CHAR_AS_STRING);
			}
			return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING DBUS_TYPE_VARIANT_AS_STRING);
		}
		if (IsObject(value)) {
			return const_cast<char*>(DBUS_TYPE_ARRAY_AS_STRING
				DBUS_DICT_ENTRY_BEGIN_CHAR_AS_STRING
				DBUS_TYPE_STRING_AS_STRING DBUS_TYPE_VARIANT_AS_STRING
				DBUS_DICT_ENTRY_END_CHAR_AS_STRING);
		}
		return "";
	}

	bool EncodeObject(Local<Value> value, DBusMessageIter *iter, const char *signature)
	{
		// printf("EncodeObject %s\n",signature);
		// printf("%p", value);
		Nan::HandleScope scope;
		DBusSignatureIter siter;
		int type;

		// Get type of current value
		dbus_signature_iter_init(&siter, signature);
		type = dbus_signature_iter_get_current_type(&siter);

		switch(type) {
		case DBUS_TYPE_INVALID:
		// case DBUS_TYPE_INVALID_AS_STRING:
		{
			printf("Invalid type\n");
		}
		break;
		case DBUS_TYPE_BOOLEAN:
		{
			dbus_bool_t data = value->BooleanValue();

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode boolean value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_INT16:
		{
			dbus_int16_t data = value->IntegerValue();
			// printf("value: %lu\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_INT64:
		{
			dbus_int64_t data = value->IntegerValue();
			// printf("value: %lu\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_UINT16:
		{
			dbus_uint16_t data = value->IntegerValue();
			// printf("value: %lu\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}
		
		case DBUS_TYPE_UINT64:
		{
			dbus_uint64_t data = value->IntegerValue();
			// printf("value: %lu\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_BYTE:
		{
			unsigned char data = value->IntegerValue();
			// printf("DBUS_TYPE_BYTE: ");
			// printf("value: %u\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_UINT32:
		{
			dbus_uint32_t data = value->Uint32Value();
			// printf("DBUS_TYPE_UINT32: ");
			// printf("value: %u\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_INT32:
		{
			dbus_int32_t data = value->Int32Value();
			// printf("DBUS_TYPE_INT32: ");
			// printf("value: %u\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode numeric value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_STRING:
		case DBUS_TYPE_OBJECT_PATH:
		case DBUS_TYPE_SIGNATURE:
		{
			char *data = strdup(*String::Utf8Value(value->ToString()));
			// printf("value: %s\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				dbus_free(data);
				printf("Failed to encode string value\n");
				return false;
			}

			dbus_free(data);

			break;
		}

		case DBUS_TYPE_DOUBLE:
		{
			double data = value->NumberValue();
			// printf("value: %f\n",data);

			if (!dbus_message_iter_append_basic(iter, type, &data)) {
				printf("Failed to encode double value\n");
				return false;
			}

			break;
		}

		case DBUS_TYPE_ARRAY:
		{
			if (!value->IsObject()) {
				printf("Failed to encode dictionary\n");
				return false;
			}

			DBusMessageIter subIter;
			DBusSignatureIter arraySiter;
			char *array_sig = NULL;

			// Getting signature of array object
			dbus_signature_iter_recurse(&siter, &arraySiter);
			array_sig = dbus_signature_iter_get_signature(&arraySiter);

			// Open array container to process elements in there
			if (!dbus_message_iter_open_container(iter, DBUS_TYPE_ARRAY, array_sig, &subIter)) {
				dbus_free(array_sig);
				printf("Can't open container for Array type\n");
				return false; 
			}

			// It's a dictionary
			if (dbus_signature_iter_get_element_type(&siter) == DBUS_TYPE_DICT_ENTRY) {

				dbus_free(array_sig);

				Local<Object> value_object = value->ToObject();
				DBusSignatureIter dictSubSiter;

				// Getting sub-signature object
				dbus_signature_iter_recurse(&arraySiter, &dictSubSiter);
				dbus_signature_iter_next(&dictSubSiter);
				char *sig = dbus_signature_iter_get_signature(&dictSubSiter);

				// process each elements
				Local<Array> prop_names = value_object->GetPropertyNames();
				unsigned int len = prop_names->Length();

				bool failed = false;
				for (unsigned int i = 0; i < len; ++i) {
					DBusMessageIter dict_iter;

					// Open dict entry container
					if (!dbus_message_iter_open_container(&subIter, DBUS_TYPE_DICT_ENTRY, NULL, &dict_iter)) {
						printf("Can't open container for DICT-ENTRY\n");
						failed = true;
						break;
					}

					// Getting the key and value
					Local<Value> prop_key = prop_names->Get(i);
					Local<Value> prop_value = value_object->Get(prop_key);

					// Append the key
					char *prop_key_str = strdup(*String::Utf8Value(prop_key->ToString()));
					// printf("key: %s\n", prop_key_str);
					dbus_message_iter_append_basic(&dict_iter, DBUS_TYPE_STRING, &prop_key_str);
					dbus_free(prop_key_str);

					// Append the value
					if (!EncodeObject(prop_value, &dict_iter, sig)) {
						dbus_message_iter_close_container(&subIter, &dict_iter); 
						printf("Failed to encode element of dictionary\n");
						failed = true;
						break;
					}

					dbus_message_iter_close_container(&subIter, &dict_iter); 
				}

				dbus_free(sig);
				dbus_message_iter_close_container(iter, &subIter);

				if (failed) 
					return false;

				break;
			}

			if (!value->IsArray()) {
				printf("Failed to encode array object\n");
				return false;
			}

			// process each elements
			Local<Array> arrayData = Local<Array>::Cast(value);
			for (unsigned int i = 0; i < arrayData->Length(); ++i) {
				Local<Value> arrayItem = arrayData->Get(i);
				if (!EncodeObject(arrayItem, &subIter, array_sig))
					break;
			}

			dbus_message_iter_close_container(iter, &subIter);
			dbus_free(array_sig);

			break;
		}

		case DBUS_TYPE_VARIANT:
		{
			DBusMessageIter subIter;

			string str_sig = GetSignatureFromV8Type(value);
			const char *var_sig = str_sig.c_str();

			if (!dbus_message_iter_open_container(iter, DBUS_TYPE_VARIANT, var_sig, &subIter)) {
				printf("Can't open container for VARIANT type\n");
				return false;
			}

			if (!EncodeObject(value, &subIter, var_sig)) { 
				dbus_message_iter_close_container(iter, &subIter);
				return false;
			}

			dbus_message_iter_close_container(iter, &subIter);

			break;
		}
		case DBUS_TYPE_STRUCT:
		{
			// printf("struct\n");
			DBusMessageIter subIter;
			DBusSignatureIter structSiter;
			
			// Open array container to process elements in there
			if (!dbus_message_iter_open_container(iter, DBUS_TYPE_STRUCT, NULL, &subIter)) {
				printf("Can't open container for Struct type\n");
				return false; 
			}

			Local<Object> value_object = value->ToObject();

			// Getting sub-signature object
			dbus_signature_iter_recurse(&siter, &structSiter);

			// process each elements
			Local<Array> prop_names = value_object->GetPropertyNames();
			unsigned int len = prop_names->Length();

			for (unsigned int i = 0; i < len; ++i) {

				char *sig = dbus_signature_iter_get_signature(&structSiter);

				Local<Value> prop_key = prop_names->Get(i);

				if (!EncodeObject(value_object->Get(prop_key), &subIter, sig)) {
					dbus_free(sig);
					printf("Failed to encode element of dictionary\n");
					return false;
				}

				dbus_free(sig);

				if (!dbus_signature_iter_next(&structSiter))
					break;
			}

			dbus_message_iter_close_container(iter, &subIter); 

			break;
		}
		default:
		{
			printf("Type not implemented: %i\n", type);
		}
		break;

		}

		return true;
	}

}

