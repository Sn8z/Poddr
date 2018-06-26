#ifndef CONNECTION_H_
#define CONNECTION_H_

namespace Connection {

	using namespace node;
	using namespace v8;
	using namespace std;

	void Init(NodeDBus::BusObject *bus);
	void UnInit(NodeDBus::BusObject *bus);
}

#endif
