import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { FavouritesService } from '../services/favourites.service';
import { OfflineService } from '../services/offline.service';
import { ToastService } from '../services/toast.service';

@Component({
	selector: 'app-favourites',
	templateUrl: './favourites.component.html',
	styleUrls: ['./favourites.component.css']
})
export class FavouritesComponent implements OnInit {
	public favourites: Array<Object> = [];
	public offlineEpisodes: Array<Object> = [];
	public content: string = 'favourites';

	constructor(private audio: AudioService, private favService: FavouritesService, private offlineService: OfflineService, private toast: ToastService) { }

	ngOnInit() {
		this.favService.favourites.subscribe(value => {
			this.favourites = value;
		});
		this.offlineService.offlineEpisodes.subscribe(value => {
			this.offlineEpisodes = value;
		});
	}

	remove = (rss) => {
		this.favService.removeFavourite(rss);
	}

	add = () => {
		this.toast.inputRSSModal().then((res) => {
			if (res.value) this.favService.addFavourite(res.value);
		});
	}

	playOffline = (episode) => {
		this.audio.loadAudio(episode, episode.author, episode.rss, "");
		this.audio.play();
	}

	removeOffline = (guid) => {
		this.offlineService.remove(guid);
	}

}
