#include <v8.h>
#include <node.h>
#include <uv.h>
#include <cstring>
#include <stdlib.h>
#include <dbus/dbus.h>
#include <nan.h>

#include "dbus.h"
#include "connection.h"
#include "signal.h"
#include "decoder.h"
#include "encoder.h"
#include "introspect.h"
#include "object_handler.h"

namespace NodeDBus {

	static void method_callback(DBusPendingCall *pending, void *user_data)
	{
		DBusError error;
		DBusMessage *reply_message;
		DBusAsyncData *data = static_cast<DBusAsyncData *>(user_data);

		dbus_error_init(&error);

		// Getting reply message
		reply_message = dbus_pending_call_steal_reply(pending);
		if (!reply_message) {
			dbus_pending_call_unref(pending);
			return;
		}
		dbus_pending_call_unref(pending);

		// Get current context from V8
		Nan::HandleScope scope;

		Local<Value> err = Nan::Null();
		if (dbus_error_is_set(&error)) {
			err = Nan::Error(error.message);
			dbus_error_free(&error);
		} else if (dbus_message_get_type(reply_message) == DBUS_MESSAGE_TYPE_ERROR) {
			err = Nan::Error(dbus_message_get_error_name(reply_message));
		}

		// Decode message for arguments
		Local<Value> result = Decoder::DecodeMessage(reply_message);
		Local<Value> info[] = {
			err,
			result
		};

		// Release
		dbus_message_unref(reply_message);

		// Invoke
		data->callback->Call(2, info);
	}

	static void method_free(void *user_data)
	{
		DBusAsyncData *data = static_cast<DBusAsyncData *>(user_data);

		data->pending = NULL;
		delete data;
	}

	NAN_METHOD(GetBus) {
		DBusConnection *connection = NULL;
		DBusError error;

		dbus_error_init(&error);

		if (!info[0]->IsNumber())
			return Nan::ThrowError("First parameter must be an integer");

		// Create connection
		switch(info[0]->IntegerValue()) {
		case NODE_DBUS_BUS_SYSTEM:
			connection = dbus_bus_get(DBUS_BUS_SYSTEM, &error);
			break;

		case NODE_DBUS_BUS_SESSION:
			connection = dbus_bus_get(DBUS_BUS_SESSION, &error);
			break;
		}

		if (connection == NULL) {
			if (dbus_error_is_set(&error))
				return Nan::ThrowError(error.message);
			else
				return Nan::ThrowError("Failed to get bus object");
		}

		// Initializing connection object
		Local<ObjectTemplate> object_template = Nan::New<ObjectTemplate>();
		object_template->SetInternalFieldCount(1);

		// Create bus object
		BusObject *bus = new BusObject;
		bus->type = static_cast<BusType>(info[0]->IntegerValue());
		bus->connection = connection;

		// Create a JavaScript object to store bus object
		Local<Object> bus_object = object_template->NewInstance();
		Nan::SetInternalFieldPointer(bus_object, 0, bus);
		bus_object->Set(Nan::New("uniqueName").ToLocalChecked(), Nan::New<String>(dbus_bus_get_unique_name(connection)).ToLocalChecked());

		// Initializing connection handler
		Connection::Init(bus);

		info.GetReturnValue().Set(bus_object);
	}

	NAN_METHOD(ReleaseBus) {
		Local<Object> bus_object = info[0]->ToObject();
		//BusObject *bus = static_cast<BusObject *>(External::Unwrap(bus_object->GetInternalField(0)));
		BusObject *bus = static_cast<BusObject *>(Nan::GetInternalFieldPointer(bus_object, 0));

		// Release connection handler
		Connection::UnInit(bus);

		return;
	}

	NAN_METHOD(CallMethod) {
		DBusError error;

		if (!info[8]->IsFunction())
			return Nan::ThrowError("Require callback function");

		int timeout = -1;
		if (info[6]->IsInt32())
			timeout = info[6]->Int32Value();

		// Get bus from internal field
		if (!info[0]->IsObject())
			return Nan::ThrowError("First argument must be an object");

		Local<Object> bus_object = info[0]->ToObject();
		BusObject *bus = static_cast<BusObject *>(Nan::GetInternalFieldPointer(bus_object, 0));

		// Initializing error handler
		dbus_error_init(&error);

		// Create message for method call
		if (!info[1]->IsString() || !info[2]->IsString() || !info[3]->IsString() || !info[4]->IsString())
			return Nan::ThrowError("Require service name, object path, interface and method");

		char *service_name = strdup(*Nan::Utf8String(info[1]));
		char *object_path = strdup(*Nan::Utf8String(info[2]));
		char *interface_name = strdup(*Nan::Utf8String(info[3]));
		char *method = strdup(*Nan::Utf8String(info[4]));

		DBusMessage *message = dbus_message_new_method_call(service_name, object_path, interface_name, method);

		dbus_free(service_name);
		dbus_free(object_path);
		dbus_free(interface_name);
		dbus_free(method);

		if (message == NULL)
			return Nan::ThrowError("Failed to call method");

		// Preparing method arguments
		if (info[7]->IsObject()) {
			DBusMessageIter iter;
			DBusSignatureIter siter;

			Local<Array> argument_arr = Local<Array>::Cast(info[7]);
			if (argument_arr->Length() > 0) {

				// Initializing augument message
				dbus_message_iter_init_append(message, &iter); 

				// Initializing signature
				char *sig = strdup(*String::Utf8Value(info[5]->ToString()));
				if (!dbus_signature_validate(sig, &error)) {
					return Nan::ThrowError(error.message);
				}

				// Getting all signatures
				dbus_signature_iter_init(&siter, sig);
				for (unsigned int i = 0; i < argument_arr->Length(); ++i) {
					char *arg_sig = dbus_signature_iter_get_signature(&siter);
					Local<Value> arg = argument_arr->Get(i);

					if (!Encoder::EncodeObject(arg, &iter, arg_sig)) {
						dbus_free(arg_sig);
						break;
					}

					dbus_free(arg_sig);

					if (!dbus_signature_iter_next(&siter))
						break;
				}

				dbus_free(sig);
			}
		}

		// Send message and call method
		if (!info[8]->IsFunction()) {

			dbus_connection_send(bus->connection, message, NULL);

		} else {

			DBusPendingCall *pending;
			if (!dbus_connection_send_with_reply(bus->connection, message, &pending, timeout) || !pending) {
				if (message != NULL)
					dbus_message_unref(message);

				return Nan::ThrowError("Failed to call method: Out of Memory");
			}

			// Set callback for waiting
			DBusAsyncData *data = new DBusAsyncData;
			data->pending = pending;
			data->callback = new Nan::Callback(info[8].As<Function>());
			if (!dbus_pending_call_set_notify(pending, method_callback, data, method_free)) {
				if (message != NULL)
					dbus_message_unref(message);

				return Nan::ThrowError("Failed to call method: Out of Memory");
			}
		}

		if (message != NULL)
			dbus_message_unref(message);

		dbus_connection_flush(bus->connection);

		return;
	}

	NAN_METHOD(RequestName) {
		if (!info[0]->IsObject()) {
			return Nan::ThrowTypeError("First argument must be an object (bus)");
		}

		if (!info[1]->IsString()) {
			return Nan::ThrowTypeError("Second argument must be a string (Bus Name)");
		}

		BusObject *bus = static_cast<BusObject *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 0));
		char *service_name = strdup(*String::Utf8Value(info[1]->ToString()));

		// Request bus name
		dbus_bus_request_name(bus->connection, service_name, 0, NULL);
		dbus_connection_flush(bus->connection);

		dbus_free(service_name);

		return;
	}

	NAN_METHOD(ParseIntrospectSource) {
		if (!info[0]->IsString()) {
			info.GetReturnValue().Set(Nan::Null());
		}
		else {

			char *src = strdup(*String::Utf8Value(info[0]->ToString()));

			Local<Value> obj = Introspect::CreateObject(src);

			dbus_free(src);

			info.GetReturnValue().Set(obj);
		}
	}

	NAN_METHOD(AddSignalFilter) {
		DBusError error;

		Local<Object> bus_object = info[0]->ToObject();
		char *rule_str = strdup(*String::Utf8Value(info[1]->ToString()));

		BusObject *bus = static_cast<BusObject *>(Nan::GetInternalFieldPointer(bus_object, 0));

		dbus_error_init(&error);

		dbus_bus_add_match(bus->connection, rule_str, &error);
		dbus_connection_flush(bus->connection);

		if (dbus_error_is_set(&error)) {
			printf("Failed to add rule: %s\n", rule_str);
			dbus_free(rule_str);

			return Nan::ThrowError(error.message);
		}

		dbus_free(rule_str);

		return;
	}

	NAN_METHOD(SetMaxMessageSize) {
		Local<Object> bus_object = info[0]->ToObject();

		BusObject *bus = static_cast<BusObject *>(Nan::GetInternalFieldPointer(bus_object, 0));

		dbus_connection_set_max_message_size(bus->connection, info[1]->ToInteger()->Value());
		dbus_connection_flush(bus->connection);

		return;
	}

	static void init(Local<Object> exports) {
		Nan::SetMethod(exports, "getBus", GetBus);
		Nan::SetMethod(exports, "releaseBus", ReleaseBus);
		Nan::SetMethod(exports, "callMethod", CallMethod);
		Nan::SetMethod(exports, "requestName", RequestName);
		Nan::SetMethod(exports, "registerObjectPath", ObjectHandler::RegisterObjectPath);
		Nan::SetMethod(exports, "sendMessageReply", ObjectHandler::SendMessageReply);
		Nan::SetMethod(exports, "sendErrorMessageReply", ObjectHandler::SendErrorMessageReply);
		Nan::SetMethod(exports, "setObjectHandler", ObjectHandler::SetObjectHandler);
		Nan::SetMethod(exports, "parseIntrospectSource", ParseIntrospectSource);
		Nan::SetMethod(exports, "setSignalHandler", Signal::SetSignalHandler);
		Nan::SetMethod(exports, "addSignalFilter", AddSignalFilter);
		Nan::SetMethod(exports, "setMaxMessageSize", SetMaxMessageSize);
		Nan::SetMethod(exports, "emitSignal", Signal::EmitSignal);

	}

	NODE_MODULE(dbus, init);
}
