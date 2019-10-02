import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { ToastService } from './toast.service';
import { HttpClient } from '@angular/common/http';
import * as app from 'electron';
import * as Store from 'electron-store';
import * as log from 'electron-log';
import * as fs from 'fs';

@Injectable({
	providedIn: 'root'
})
export class OfflineService {
	private store: Store<any> = new Store({ name: "offline", accessPropertiesByDotNotation: false });

	public offlineEpisodes: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);
	public offlineKeys: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);

	constructor(private http: HttpClient, private toast: ToastService) {
		this.updateOfflineEpisodes();
	}

	private updateOfflineEpisodes = () => {
		this.offlineEpisodes.next(Object.values(this.store.store) as Object[]);
		this.offlineKeys.next(Object.keys(this.store.store as string[]));
	}

	remove = (guid) => {
		const filePath = this.store.get(guid).src;
		log.info("Offline service :: Removing offline episode: " + filePath);
		fs.unlink(filePath, (error) => {
			if (error) {
				log.error("Offline service :: " + error);
			} else {
				log.info("Offline service :: Successfully removed " + filePath);
			}
		});
		this.store.delete(guid);
		this.updateOfflineEpisodes();
	}

	download = (title, rss, podcastObject) => {
		this.toast.toast("Downloading " + podcastObject.title);

		const storagePath = app.remote.app.getPath('downloads') + '/Poddr/';

		log.info("Offline service :: Checking if download folder exists...");
		if (fs.existsSync(storagePath)) {
			log.info("Offline service :: Download folder exists.");
		} else {
			log.info("Offline service :: Creating download folder at: " + storagePath);
			fs.mkdirSync(storagePath, { recursive: true });
		}

		this.http.get(podcastObject.enclosure.url, { responseType: 'arraybuffer' }).subscribe((response) => {
			const fileName = (title.toLowerCase() + "-" + podcastObject.title.toLowerCase() + "." + this.getFileExtension(podcastObject.enclosure.type)).replace(/\W/g, '_');
			fs.writeFile(storagePath + fileName, Buffer.from(response), (error) => {
				if (error) {
					log.error("Offline service :: An error ocurred creating the file > ERROR MSG: " + error.message);
					this.toast.toastError("Something went wrong with the download.");
				} else {
					const podcast = { episodeTitle: podcastObject.title, author: title, rss: rss, guid: podcastObject.guid, src: storagePath + fileName };
					this.store.set(podcastObject.guid, podcast);
					log.info("Offline service :: Saved file at: " + storagePath + fileName);
					this.toast.toastSuccess("Completed " + podcastObject.title);
					this.updateOfflineEpisodes();
				}
			});
		});
	}

	private getFileExtension = (type) => {
		switch (type) {
			case "audio/mpeg":
				return "mp3";
			case "audio/x-m4a":
				return "m4a";
			case "audio/ogg":
				return "ogg";
			case "audio/wav":
				return "wav";
			case "audio/webm":
				return "webm";
			case "audio/flac":
				return "flac";
			default:
				return "mp3";
		}
	}
}
