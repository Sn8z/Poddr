import { Application } from 'spectron';
import { PlayedService } from './played.service';
import test from 'ava';

const timeout = 10000;
let service: PlayedService;
let app;

test.before(async t => {
	app = new Application({
		path: './node_modules/.bin/electron',
		args: ['main.js'],
		startTimeout: timeout,
		waitTimeout: timeout
	});

	//service = new PlayedService();

	return await app.start();
});

test.after.always(async t => {
	if (app && app.isRunning()) {
		return await app.stop();
	}
});
