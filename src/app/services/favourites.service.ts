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

	public favourites: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);
	public favouriteKeys: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);
	public favouriteTitles: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);
	public latestEpisodes: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);

	public dParser: DOMParser = new DOMParser();

	constructor(private podcastService: PodcastService, private toast: ToastService) {
		this.updateFavourites();
	}

	private updateFavourites = () => {
		this.favourites.next(Object.values(this.store.store) as Object[]);
		this.favouriteKeys.next(Object.keys(this.store.store) as string[]);
		this.favouriteTitles.next(Object.values(this.store.store).map((x: any) => { return x.title; }) as string[]);
		this.getLatestFavouriteEpisodes();
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

	getLatestFavouriteEpisodes = () => {
		this.favourites.value.forEach((x: any) => {
			this.podcastService.getPodcastFeed(x.rss).subscribe(rss => {
				const currentPodcastEpisodes = [];
				parsePodcast(rss, (error, data) => {
					if (error) {
						log.error("Favourite service :: " + error);
					} else {
						data.episodes.forEach(y => {
							const episode = {
								title: y.title,
								podcast: data.title,
								src: y.enclosure.url,
								cover: y.image || data.image,
								guid: y.guid,
								rss: x.rss,
								date: y.published
							}
							currentPodcastEpisodes.push(episode);
						})
					}
				})

				const currentValue = this.latestEpisodes.value;
				const updatedValue = [...currentValue, ...currentPodcastEpisodes];
				this.latestEpisodes.next(updatedValue);


				/*
				const feed = this.dParser.parseFromString(rss, "text/xml");
				const episodes = Array.from(feed.querySelectorAll('item'));
				episodes.forEach(m => {
					log.info(m.querySelector('title').innerHTML);
					const episode = {
						title: m.querySelector('title').innerHTML,
						podcast: feed.querySelector('title').innerHTML,
						src: m.querySelector('enclosure').getAttribute('url') || "",
						cover: m.querySelector("itunes\\:image").getAttribute('href') || "",
						guid: m.querySelector('guid').innerHTML,
						rss: x,
						date: m.querySelector('pubDate').innerHTML
					}
					currentPodcastEpisodes.push(episode);
				})
				*/
			})
		})
	}
}
