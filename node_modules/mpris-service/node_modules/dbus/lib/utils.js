"use strict";

var Define = function(type, name) {

	var dataDef = {
		type: Signature(type)
	};

	if (name)
		dataDef.name = name;

	return dataDef;
};

var Signature = function(type) {
	if (type == 'Auto') {
		return 'v';
	} else if (type === String) {
		return 's';
	} else if (type === Number) {
		return 'd';
	} else if (type === Boolean) {
		return 'b';
	} else if (type === Array) {
		return 'av';
	} else if (type === Object) {
		return 'a{sv}';
	} 

	return 'v';
};

var ForEachAsync = function(arr, callback, complete) {
	var nextTick = process.nextTick;
	if (setImmediate)
		nextTick = setImmediate;

	function next(index, length) {
		var self = this;

		if (index >= length) {
			if (complete)
				complete.apply(this, [ true ]);

			return;
		}

		function _next(stop) {
			if (stop === false) {

				if (complete)
					complete.apply(this, [ false ]);
				
				return;
			}

			nextTick(function() {
				if (ret === false) {

					if (complete)
						complete.apply(this, [ false ]);

					return;
				}

				next.apply(self, [ index + 1, length ]);
			});
		}

		var ret = callback.apply(self, [ arr[index], index, arr, _next ]);

		if (ret != true)
			_next();
	}

	next.apply(this, [ 0, arr.length ]);
};

module.exports = {
	Define: Define,
	Signature: Signature,
	ForEachAsync: ForEachAsync
};
