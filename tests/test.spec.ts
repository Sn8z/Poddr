import { Application } from 'spectron';
import test from 'ava';

const timeout = 10000;
let app;

test.before(async t => {
	app = new Application({
		path: './node_modules/.bin/electron',
		args: ['main.js'],
		startTimeout: timeout,
		waitTimeout: timeout,
	});
	return await app.start();
});

test.after.always(async t => {
	if (app && app.isRunning()) {
		return await app.stop();
	}
});

test('Window was launched', async t => {
	t.is(await app.client.getWindowCount(), 1);
});

test('Client got correct title', async t => {
	t.is(await app.client.getTitle(), 'Poddr');
});

test('Client has a height and width', async t => {
	const { width, height } = await app.browserWindow.getBounds();
	t.true(width > 0);
	t.true(height > 0);
});