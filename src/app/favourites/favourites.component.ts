import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { FavouritesService } from '../services/favourites.service';
import { OfflineService } from '../services/offline.service';
import { ToastService } from '../services/toast.service';
import { faPlus, faTimes } from '@fortawesome/free-solid-svg-icons';

@Component({
	selector: 'app-favourites',
	templateUrl: './favourites.component.html',
	styleUrls: ['./favourites.component.css']
})
export class FavouritesComponent implements OnInit {
	public favourites: Array<Object> = [];
	public offlineEpisodes: Array<Object> = [];
	public content: string = 'favourites';

	public faPlus = faPlus;
	public faTimes = faTimes;

	constructor(private audio: AudioService, private favService: FavouritesService, private offlineService: OfflineService, private toast: ToastService) { }

	ngOnInit() {
		this.favService.favourites.subscribe(value => {
			this.favourites = value;
		});
		this.offlineService.offlineEpisodes.subscribe(value => {
			this.offlineEpisodes = value;
		});
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
