#include <v8.h>
#include <node.h>
#include <cstring>
#include <dbus/dbus.h>
#include <nan.h>

#include "dbus.h"
#include "decoder.h"
#include "encoder.h"
#include "object_handler.h"

namespace ObjectHandler {

	using namespace node;
	using namespace v8;
	using namespace std;

	Nan::Persistent<Function> handler;

	// Initializing object handler table
	static DBusHandlerResult MessageHandler(DBusConnection *connection, DBusMessage *message, void *user_data)
	{
		Nan::HandleScope scope;

		const char *sender = dbus_message_get_sender(message);
		const char *object_path = dbus_message_get_path(message);
		const char *interface = dbus_message_get_interface(message);
		const char *member = dbus_message_get_member(message);

		// Create a object template
		Local<ObjectTemplate> object_template = Nan::New<ObjectTemplate>();
		object_template->SetInternalFieldCount(2);

		// Store connection and message
		Local<Object> message_object = object_template->NewInstance();
		Nan::SetInternalFieldPointer(message_object, 0, connection);
		Nan::SetInternalFieldPointer(message_object, 1, message);

		// Getting arguments
		Local<Value> arguments = Decoder::DecodeArguments(message);

		Local<Value> info[] = {
			Nan::New<String>(dbus_bus_get_unique_name(connection)).ToLocalChecked(),
			Nan::New<String>(sender).ToLocalChecked(),
			Nan::New<String>(object_path).ToLocalChecked(),
			Nan::New<String>(interface).ToLocalChecked(),
			Nan::New<String>(member).ToLocalChecked(),
			message_object,
			arguments
		};

		// Keep message live for reply
		if (!dbus_message_get_no_reply(message))
			dbus_message_ref(message);

		// Invoke
		Nan::MakeCallback(Nan::GetCurrentContext()->Global(), Nan::New(handler), 7, info);

		return DBUS_HANDLER_RESULT_HANDLED;
	}

	static void UnregisterMessageHandler(DBusConnection *connection, void *user_data)
	{
	}

	static inline DBusObjectPathVTable CreateVTable()
	{
		DBusObjectPathVTable vt;

		vt.message_function = MessageHandler;
		vt.unregister_function = UnregisterMessageHandler;

		return vt;
	}

	static void _SendMessageReply(DBusConnection *connection, DBusMessage *message, Local<Value> reply_value, char *signature)
	{
		Nan::HandleScope scope;
		DBusMessageIter iter;
		DBusSignatureIter siter;
		DBusMessage *reply;
		dbus_uint32_t serial = 0;

		reply = dbus_message_new_method_return(message);

		dbus_message_iter_init_append(reply, &iter);
		dbus_signature_iter_init(&siter, signature);
		if (!Encoder::EncodeObject(reply_value, &iter, &siter)) {
			printf("Failed to encode reply value\n");
		}

		// Send reply message
		dbus_connection_send(connection, reply, &serial);
		dbus_connection_flush(connection);

		dbus_message_unref(reply);
	}

	DBusObjectPathVTable vtable = CreateVTable();

	NAN_METHOD(RegisterObjectPath) {
		DBusError error;
		if (!info[0]->IsObject()) {
			return Nan::ThrowTypeError("First parameter must be an object (bus)");
		}

		if (!info[1]->IsString()) {
			return Nan::ThrowTypeError("Second parameter must be a string (object path)");
		}

		NodeDBus::BusObject *bus = static_cast<NodeDBus::BusObject *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 0));

		// Register object path
		char *object_path = strdup(*Nan::Utf8String(info[1]));
		dbus_error_init(&error);
		dbus_bool_t ret = dbus_connection_try_register_object_path(bus->connection,
			object_path,
			&vtable,
			NULL,
			&error);
		dbus_connection_flush(bus->connection);
		dbus_free(object_path);
		if (dbus_error_is_set(&error)) {
			return Nan::ThrowError(error.message);
		}

		return;
	}

	NAN_METHOD(UnregisterObjectPath) {
		if (!info[0]->IsObject()) {
			return Nan::ThrowTypeError("First parameter must be an object (bus)");
		}

		if (!info[1]->IsString()) {
			return Nan::ThrowTypeError("Second parameter must be a string (object path)");
		}

		NodeDBus::BusObject *bus = static_cast<NodeDBus::BusObject *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 0));

		// Register object path
		char *object_path = strdup(*Nan::Utf8String(info[1]));
		dbus_bool_t ret = dbus_connection_unregister_object_path(bus->connection,
			object_path);
		dbus_connection_flush(bus->connection);
		dbus_free(object_path);
		if (!ret) {
			return Nan::ThrowError("Out of Memory");
		}

		return;
	}

	NAN_METHOD(SendMessageReply) {
		if (!info[0]->IsObject()) {
			return Nan::ThrowTypeError("First parameter must be an object");
		}

		DBusConnection *connection = static_cast<DBusConnection *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 0));
		DBusMessage *message = static_cast<DBusMessage *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 1));

		if (dbus_message_get_no_reply(message)) {
			return;
		}

		char *signature = strdup(*Nan::Utf8String(info[2]));
		_SendMessageReply(connection, message, info[1], signature);
		dbus_free(signature);

		return;
	}

	NAN_METHOD(SendErrorMessageReply) {
		if (!info[0]->IsObject()) {
			return Nan::ThrowTypeError("First parameter must be an object");
		}

		DBusConnection *connection = static_cast<DBusConnection *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 0));
		DBusMessage *message = static_cast<DBusMessage *>(Nan::GetInternalFieldPointer(info[0]->ToObject(), 1));

		// Getting error message from arguments
		char *name = strdup(*Nan::Utf8String(info[1]));
		char *msg = strdup(*Nan::Utf8String(info[2]));

		// Initializing error message
		DBusMessage *error_message = dbus_message_new_error(message, name, msg);

		// Send error message
		dbus_connection_send(connection, error_message, NULL);
		dbus_connection_flush(connection);

		// Release
		dbus_message_unref(error_message);
		dbus_free(name);
		dbus_free(msg);

		return;
	}

	NAN_METHOD(SetObjectHandler) {
		if (!info[0]->IsFunction()) {
			return Nan::ThrowTypeError("First parameter must be a function");
		}

		handler.Reset();
		handler.Reset(info[0].As<Function>());

		return;
	}
}

