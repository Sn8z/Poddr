import { Application } from 'spectron';
import { AudioService } from './audio.service';
import { FavouritesService } from './favourites.service';
import { HotkeysService } from './hotkeys.service';
import { OfflineService } from './offline.service';
import { PlayedService } from './played.service';
import { PodcastService } from './podcast.service';
import { ToastService } from './toast.service';
import test from 'ava';

const timeout = 10000;
let toast: ToastService;
let app;

test.before(async t => {
	app = new Application({
		path: './node_modules/.bin/electron',
		args: ['main.js'],
		startTimeout: timeout,
		waitTimeout: timeout
	});
	toast = new ToastService();
	return await app.start();
});

test.after.always(async t => {
	if (app && app.isRunning()) {
		return await app.stop();
	}
});

test('Toast service exists', async t => {
	await app.client.waitUntilWindowLoaded();
	t.truthy(toast);
});