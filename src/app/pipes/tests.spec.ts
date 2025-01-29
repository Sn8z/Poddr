import { Application } from 'spectron';
import { Description } from './description.pipe';
import { ItunesImage } from './itunes-image.pipe';
import { SecondsToHhMmSs } from './secondsToHhMmSs.pipe';
import test from 'ava';

const timeout = 10000;
let app;

test.before(async t => {
	app = await new Application({
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

test('Seconds to text conversion', async t => {
	await app.client.waitUntilWindowLoaded();
	const timePipe = new SecondsToHhMmSs();
	t.is(timePipe.transform(50), "00:00:50");
	t.is(timePipe.transform(70), "00:01:10");
	t.is(timePipe.transform(3600), "01:00:00");
	t.is(timePipe.transform(3661), "01:01:01");
	t.is(timePipe.transform(-1), "00:00:00");
});

test('Description filtering', async t => {
	await app.client.waitUntilWindowLoaded();
	const descPipe = new Description();
	t.is(descPipe.transform("Hejsan"), "Hejsan");
	t.is(descPipe.transform("Hejsan<br> Hoppsan"), "Hejsan Hoppsan");
	t.is(descPipe.transform("Hejsan <br> Hoppsan"), "Hejsan Hoppsan");
	t.is(descPipe.transform("Hej<br><br><br><br>san"), "Hejsan");
	t.is(descPipe.transform("Hallå"), "Hallå");
});

test('Itunes URL Pipe', async t => {
	await app.client.waitUntilWindowLoaded();
	const itunesPipe = new ItunesImage();
	t.is(itunesPipe.transform("test60x60test"), "test250x250test");
});