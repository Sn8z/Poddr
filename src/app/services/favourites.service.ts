import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { PodcastService } from './podcast.service';
import { ToastService } from './toast.service';
import * as Store from 'electron-store';
import * as parsePodcast from 'node-podcast-parser';
import * as log from 'electron-log';


@Injectable({
	providedIn: 'root'
})
export class FavouritesService {
	private store: Store<any> = new Store({ name: "favourites" });

	favourites: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);
	favouriteKeys: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);
	favouriteTitles: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);

	constructor(private podcastService: PodcastService, private toast: ToastService) {
		this.updateFavourites();
	}

	private updateFavourites = () => {
		this.favourites.next(Object.values(this.store.store) as Object[]);
		this.favouriteKeys.next(Object.keys(this.store.store) as string[]);
		this.favouriteTitles.next(Object.values(this.store.store).map((x: any) => { return x.title; }) as string[]);
	}

	addItunesFavourite = (id) => {
		this.podcastService.getRssFeed(id).subscribe((data) => {
			this.addFavourite(data['results'][0]['feedUrl']);
		});
	}

	addFavourite = (rss, silent: Boolean = false) => {
		this.podcastService.getPodcastFeed(rss).subscribe((response) => {
			parsePodcast(response, (error, data) => {
				if (error) {
					log.error("Favourite service :: " + error);
					if (!silent) this.toast.toastError("Something went wrong when parsing RSS feed.");
				} else {
					this.store.set(rss.replace(/\./g, '\\.'), {
						rss: rss,
						title: data.title,
						img: data.image,
						dateAdded: Date.now()
					});
					if (!silent) this.toast.toastSuccess("Added " + data.title + " to favourites!");
					this.updateFavourites();
					log.info("Favourite service :: Added " + data.title + " to favourites.");
				}
			})
		});
	}

	removeFavourite = (rss) => {
		this.store.delete(rss.replace(/\./g, '\\.'));
		this.toast.toastError("Unfollowed podcast");
		this.updateFavourites();
		log.info("Favourite service :: Removed " + rss + " from favourites.");
	}
}
