var util = require('util');

function DBusError(name, message) {
	Error.call(this, message);
	this.message = message;
	this.dbusName = name;

	if (Error.captureStackTrace) {
		Error.captureStackTrace(this, 'DBusError');
	}
	else {
		Object.defineProperty(this, 'stack', { value: (new Error()).stack });
	}
}

util.inherits(DBusError, Error);

DBusError.prototype.toString = function() {
	return 'DBusError: ' + this.message;
}

module.exports = DBusError;
