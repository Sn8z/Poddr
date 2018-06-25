var child_process = require('child_process');
var path = require('path');

function withService(name, callback) {
	// Start a new process with our service code.
	var p = child_process.fork(path.join(__dirname, name));

	var done = function() {
		p.send({ message: 'done' });
	}

	done.process = p;

	p.on('message', function(m) {
		if (m.message === 'ready') {
			// When the service process has started and notifies us that it
			// is ready, we call the callback so that the test code can
			// proceed.
			callback(null, done);
		}
	});
}

module.exports = withService;
