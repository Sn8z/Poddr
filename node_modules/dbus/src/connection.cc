#include <stdlib.h>
#include <v8.h>
#include <node.h>
#include <string>
#include <cstring>
#include <stdlib.h>
#include <dbus/dbus.h>
#include <nan.h>

#include "dbus.h"
#include "decoder.h"
#include "connection.h"
#include "signal.h"

namespace Connection {

	using namespace node;
	using namespace v8;
	using namespace std;

	static void connection_loop_free(uv_handle_t* handle) {
		uv_async_t *connection_loop = reinterpret_cast<uv_async_t *>(handle);
		delete connection_loop;
	}

	static void watcher_free(uv_handle_t* handle) {
		uv_poll_t *watcher = reinterpret_cast<uv_poll_t *>(handle);
		delete watcher;
	}

	static void timer_free(uv_handle_t* handle) {
		uv_timer_t *timer = reinterpret_cast<uv_timer_t *>(handle);
		delete timer;
	}

	static void watcher_handle(uv_poll_t *watcher, int status, int events)
	{
		DBusWatch *watch = static_cast<DBusWatch *>(watcher->data);
		unsigned int flags = 0;

		if (events & UV_READABLE)
			flags |= DBUS_WATCH_READABLE;

		if (events & UV_WRITABLE)
			flags |= DBUS_WATCH_WRITABLE;

		dbus_watch_handle(watch, flags);
	}

	static void watcher_close(void *data)
	{
		uv_poll_t *watcher = static_cast<uv_poll_t *>(data);

		if (watcher == NULL)
			return;

		watcher->data = NULL;

		// Stop watching
		uv_ref((uv_handle_t *)watcher);
		uv_poll_stop(watcher);
		uv_close((uv_handle_t *)watcher, (uv_close_cb)watcher_free);
	}

	static dbus_bool_t watch_add(DBusWatch *watch, void *data)
	{
		if (!dbus_watch_get_enabled(watch) || dbus_watch_get_data(watch) != NULL)
			return true;

		int events = 0;
		int fd = dbus_watch_get_unix_fd(watch);
		unsigned int flags = dbus_watch_get_flags(watch);

		if (flags & DBUS_WATCH_READABLE)
			events |= UV_READABLE;

		if (flags & DBUS_WATCH_WRITABLE)
			events |= UV_WRITABLE;

		// Initializing watcher
		uv_poll_t *watcher = new uv_poll_t;
		watcher->data = (void *)watch;

		// Start watching
		uv_poll_init(uv_default_loop(), watcher, fd);
		uv_poll_start(watcher, events, watcher_handle);
		uv_unref((uv_handle_t *)watcher);

		dbus_watch_set_data(watch, (void *)watcher, watcher_close);

		return true;
	}

	static void watch_remove(DBusWatch *watch, void *data)
	{
		uv_poll_t *watcher = static_cast<uv_poll_t *>(dbus_watch_get_data(watch));

		if (watcher == NULL)
			return;

		dbus_watch_set_data(watch, NULL, NULL);
	}

	static void watch_handle(DBusWatch *watch, void *data)
	{
		// This watch was never added, so don't do anything!
		// If we would react in this case, it can happen that we add
		// two watches for one filehandler, this crashes libuv!
		if (dbus_watch_get_data(watch) == NULL) {
			return;
		}

		if (dbus_watch_get_enabled(watch))
			watch_add(watch, data);
		else
			watch_remove(watch, data);
	}

#if UV_VERSION_MAJOR == 0
	static void timer_handle(uv_timer_t *timer, int status)
#else
	static void timer_handle(uv_timer_t *timer)
#endif
	{
		DBusTimeout *timeout = static_cast<DBusTimeout *>(timer->data);
		dbus_timeout_handle(timeout);
	}

	static void timer_close(void *data)
	{
		uv_timer_t *timer = static_cast<uv_timer_t *>(data);

		if (timer == NULL)
			return;

		timer->data =  NULL;

		// Stop timer
		uv_timer_stop(timer);
		uv_unref((uv_handle_t *)timer);
		uv_close((uv_handle_t *)timer, (uv_close_cb)timer_free);
	}

	static dbus_bool_t timeout_add(DBusTimeout *timeout, void *data)
	{
		if (!dbus_timeout_get_enabled(timeout) || dbus_timeout_get_data(timeout) != NULL)
			return true;

		uv_timer_t *timer = new uv_timer_t;
		timer->data = timeout;

		// Initializing timer
		uv_timer_init(uv_default_loop(), timer);
		uv_timer_start(timer, timer_handle, dbus_timeout_get_interval(timeout), 0);

		dbus_timeout_set_data(timeout, (void *)timer, timer_close);

		return true;
	}

	static void timeout_remove(DBusTimeout *timeout, void *data)
	{
		dbus_timeout_set_data(timeout, NULL, NULL);
	}

	static void timeout_toggled(DBusTimeout *timeout, void *data)
	{
		if (dbus_timeout_get_enabled(timeout))
			timeout_add(timeout, data);
		else
			timeout_remove(timeout, data);
	}

#if UV_VERSION_MAJOR == 0
	static void connection_loop_handle(uv_async_t *connection_loop, int status)
#else
	static void connection_loop_handle(uv_async_t *connection_loop)
#endif
	{
		DBusConnection *connection = static_cast<DBusConnection *>(connection_loop->data);
		dbus_connection_read_write(connection, 0);

		while(dbus_connection_dispatch(connection) == DBUS_DISPATCH_DATA_REMAINS);
	}

	static void connection_loop_close(void *data) {
		uv_async_t *connection_loop = static_cast<uv_async_t *>(data);

		if (connection_loop == NULL)
			return;

		connection_loop->data = NULL;

		uv_close((uv_handle_t *)connection_loop, (uv_close_cb)connection_loop_free);
	}

	static void connection_wakeup(void *data)
	{
		uv_async_t *connection_loop = static_cast<uv_async_t *>(data);
		uv_async_send(connection_loop);
	}

	static DBusHandlerResult signal_filter(DBusConnection *connection, DBusMessage *message, void *user_data)
	{
		// Ignore message if it's not a valid signal
		if (dbus_message_get_type(message) != DBUS_MESSAGE_TYPE_SIGNAL) {
			return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
		}

		// Getting the interface name and signal name
		const char *sender = dbus_message_get_sender(message);
		const char *object_path = dbus_message_get_path(message);
		const char *interface = dbus_message_get_interface(message);
		const char *signal_name = dbus_message_get_member(message);
		if (interface == NULL || signal_name == NULL) {
			return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
		}

		// Getting V8 context
/*
		Local<Context> context = Context::GetCurrent();
		Context::Scope ctxScope(context);
		HandleScope scope;
*/
		Nan::HandleScope scope;

		// Getting arguments of signal
		Local<Value> arguments = Decoder::DecodeArguments(message);
		Local<Value> senderValue = Nan::Null();
		if (sender)
			senderValue = Nan::New<String>(sender).ToLocalChecked();

		Local<Value> info[] = {
			Nan::New<String>(dbus_bus_get_unique_name(connection)).ToLocalChecked(),
			senderValue,
			Nan::New<String>(object_path).ToLocalChecked(),
			Nan::New<String>(interface).ToLocalChecked(),
			Nan::New<String>(signal_name).ToLocalChecked(),
			arguments
		};

		Signal::DispatchSignal(info);

		return DBUS_HANDLER_RESULT_HANDLED;
	}

	void Init(NodeDBus::BusObject *bus)
	{
		DBusConnection *connection = bus->connection;

		dbus_connection_set_exit_on_disconnect(connection, false);

		// Initializing watcher
		dbus_connection_set_watch_functions(connection, watch_add, watch_remove, watch_handle, NULL, NULL);

		// Initializing timeout handlers
		dbus_connection_set_timeout_functions(connection, timeout_add, timeout_remove, timeout_toggled, NULL, NULL);

		// Initializing loop
		uv_async_t *connection_loop = new uv_async_t;
		connection_loop->data = (void *)connection;
		uv_async_init(uv_default_loop(), connection_loop, connection_loop_handle);
		bus->loop = connection_loop;

		dbus_connection_set_wakeup_main_function(connection, connection_wakeup, connection_loop, connection_loop_close);

		// Initializing signal handler
		dbus_connection_add_filter(connection, signal_filter, NULL, NULL);
	}

	void UnInit(NodeDBus::BusObject *bus)
	{
		DBusConnection *connection = bus->connection;

		uv_unref((uv_handle_t *)bus->loop);

		dbus_connection_unref(connection);
	}

}

