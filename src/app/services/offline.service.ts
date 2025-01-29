import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { ToastService } from './toast.service';
import { HttpClient } from '@angular/common/http';
import { throwError } from 'rxjs';
import { retry, timeout, catchError } from 'rxjs/operators'
import { ipcRenderer } from 'electron';
import Store from 'electron-store';
import * as log from 'electron-log';
import * as fs from 'fs';

@Injectable({
	providedIn: 'root'
})
export class OfflineService {
	private store: Store<any> = new Store({ name: "offline", accessPropertiesByDotNotation: false });
	private storagePath: string = "";

	public offlineEpisodes: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);
	public offlineKeys: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);

	constructor(private http: HttpClient, private toast: ToastService) {
		ipcRenderer.invoke('downloadStorage').then((result) => {
			this.storagePath = result;
			this.updateOfflineEpisodes();
		});
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
		this.toast.toastError("Removed offline episode.");
		this.updateOfflineEpisodes();
	}

	download = (title, rss, podcastObject) => {
		this.toast.toast("Downloading " + podcastObject.title);

		log.info("Offline service :: Checking if download folder exists...");
		if (fs.existsSync(this.storagePath)) {
			log.info("Offline service :: Download folder exists.");
		} else {
			log.info("Offline service :: Creating download folder at: " + this.storagePath);
			fs.mkdirSync(this.storagePath, { recursive: true });
		}

		this.getPodcast(podcastObject).subscribe((response) => {
			const fileName = (title.toLowerCase() + "-" + podcastObject.title.toLowerCase() + "." + this.getFileExtension(podcastObject.enclosure.type)).replace(/\W/g, '_');
			fs.writeFile(this.storagePath + fileName, Buffer.from(response), (error) => {
				if (error) {
					log.error("Offline service :: An error ocurred creating the file > ERROR MSG: " + error.message);
					this.toast.toastError("Something went wrong with the download.");
				} else {
					const podcast = { episodeTitle: podcastObject.title, author: title, rss: rss, guid: podcastObject.guid, src: this.storagePath + fileName };
					this.store.set(podcastObject.guid, podcast);
					log.info("Offline service :: Saved file at: " + this.storagePath + fileName);
					this.toast.toastSuccess("Completed " + podcastObject.title);
					this.updateOfflineEpisodes();
				}
			});
		});
	}

	getPodcast = (podcastObject) => {
		log.info("Offline service :: downloading from => " + podcastObject.enclosure.url);
		return this.http.get(podcastObject.enclosure.url, { responseType: 'arraybuffer' }).pipe(
			timeout(10000),
			retry(3),
			catchError((error) => {
				log.error('Offline service :: ' + JSON.stringify(error));
				this.toast.toastError('Something went wrong when trying to download an episode.');
				return throwError(error);
			})
		);
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
