import { Component, OnDestroy, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { FavouritesService } from '../services/favourites.service';
import { OfflineService } from '../services/offline.service';
import { ToastService } from '../services/toast.service';
import { faPlus, faTimes } from '@fortawesome/free-solid-svg-icons';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-favourites',
    templateUrl: './favourites.component.html',
    styleUrls: ['./favourites.component.css'],
    standalone: false
})
export class FavouritesComponent implements OnInit, OnDestroy {
	private offlineSubscription: Subscription;
	private favSubscription: Subscription;
	private favEpisodesSubscription: Subscription;

	public favourites: Array<Object> = [];
	public offlineEpisodes: Array<Object> = [];
	public latestEpisodes: Array<Object> = [];
	public content: string = 'favourites';

	public faPlus = faPlus;
	public faTimes = faTimes;

	constructor(private audio: AudioService, private favService: FavouritesService, private offlineService: OfflineService, private toast: ToastService) { }

	ngOnInit() {
		this.favSubscription = this.favService.favourites.subscribe(value => {
			this.favourites = value;
		});
		this.offlineSubscription = this.offlineService.offlineEpisodes.subscribe(value => {
			this.offlineEpisodes = value;
		});
		this.favEpisodesSubscription = this.favService.latestEpisodes.subscribe(value => {
			this.latestEpisodes = value.sort((a, b) => {
				const aDate = new Date(a['date']);
				const bDate = new Date(b['date']);
				return aDate > bDate ? -1 : bDate > aDate ? 1 : 0;
			}).slice(0, 100);
		});
	}

	ngOnDestroy() {
		if (this.favSubscription) this.favSubscription.unsubscribe();
		if (this.offlineSubscription) this.offlineSubscription.unsubscribe();
		if (this.favEpisodesSubscription) this.favEpisodesSubscription.unsubscribe();
	}

	remove = (rss): void => {
		this.toast.confirmModal().then((res) => {
			if (res.value) this.favService.removeFavourite(rss);
		});
	}

	add = (): void => {
		this.toast.inputRSSModal().then((res) => {
			if (res.value) this.favService.addFavourite(res.value);
		});
	}

	playEpisode = (episode) => {
		episode.episodeTitle = episode.title;
		this.audio.loadAudio(episode, episode.podcast, episode.rss, episode.cover);
		this.audio.play();
	}

	playOffline = (episode): void => {
		this.audio.loadAudio(episode, episode.author, episode.rss, "");
		this.audio.play();
	}

	removeOffline = (guid): void => {
		this.toast.confirmModal().then((res) => {
			if (res.value) this.offlineService.remove(guid);
		});
	}
}
