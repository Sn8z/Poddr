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

	constructor(private podcastService: PodcastService, private toast: ToastService) {
		this.updateFavourites();
		this.getLatestFavouriteEpisodes();
	}

	private updateFavourites = (): void => {
		this.favourites.next(Object.values(this.store.store) as Object[]);
		this.favouriteKeys.next(Object.keys(this.store.store) as string[]);
		this.favouriteTitles.next(Object.values(this.store.store).map((x: any) => { return x.title; }) as string[]);
	}

	addItunesFavourite = (id: string): void => {
		this.podcastService.getRssFeed(id).subscribe((data) => {
			this.addFavourite(data['results'][0]['feedUrl']);
		});
	}

	addFavourite = (rss: string, silent: Boolean = false) => {
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
					log.info("Favourite service :: Added " + data.title + " to favourites.");
					this.addEpisodesToLatest(rss);
					this.updateFavourites();
				}
			})
		});
	}

	addEpisodesToLatest = (rss: string): void => {
		fetch(rss).then((response) => {
			return response.text();
		}).then((data) => {
			parsePodcast(data, (error, data) => {
				if (error) {
					log.error(error);
				} else {
					let podcastEpisodes = [];
					data.episodes.forEach(y => {
						const episode = {
							title: y.title || 'Podcast',
							podcast: data.title || 'Podcast Title',
							src: y.enclosure ? y.enclosure.url || '' : '',
							cover: y.image || data.image,
							guid: y.guid || '',
							rss: rss || '',
							date: y.published || ''
						}
						podcastEpisodes.push(episode);
					})
					this.latestEpisodes.next([...this.latestEpisodes.value, ...podcastEpisodes]);
				}
			});
		}).catch((error) => {
			log.error(error);
		});
	}

	removeFavourite = (rss: string): void => {
		this.store.delete(rss.replace(/\./g, '\\.'));
		this.toast.toastError("Unfollowed podcast");
		this.removeEpisodesFromLatest(rss);
		this.updateFavourites();
		log.info("Favourite service :: Removed " + rss + " from favourites.");
	}

	removeEpisodesFromLatest = (rss: string): void => {
		let updateValue = this.latestEpisodes.value.filter((episode: any) => {
			return episode.rss !== rss;
		});
		this.latestEpisodes.next(updateValue);
	}

	getLatestFavouriteEpisodes = (): void => {
		let updatedValue = [];
		const promises = [];
		this.favourites.value.forEach((fav: any) => {
			const promise = fetch(fav.rss)
				.then((response) => {
					return response.text();
				}).then((data) => {
					const currentPodcastEpisodes = [];
					parsePodcast(data, (error, data) => {
						if (error) {
							log.error("Favourite service :: " + error);
						} else {
							data.episodes.forEach(y => {
								const episode = {
									title: y.title || 'Podcast',
									podcast: data.title || 'Podcast Title',
									src: y.enclosure ? y.enclosure.url || '' : '',
									cover: y.image || data.image,
									guid: y.guid || '',
									rss: fav.rss || '',
									date: y.published || ''
								}
								currentPodcastEpisodes.push(episode);
							})
						}
					})
					updatedValue = [...updatedValue, ...currentPodcastEpisodes];
				}).catch((error) => {
					log.error(error);
				});
			promises.push(promise);
		});
		Promise.all(promises).then(() => {
			this.latestEpisodes.next(updatedValue);
		}).catch((error) => {
			log.error("Favourite service :: " + error);
		});
	}
}
