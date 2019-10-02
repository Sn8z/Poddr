import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';
import { ToastService } from '../services/toast.service';
import { Description } from '../pipes/description.pipe';
import * as Store from 'electron-store';

@Component({
	selector: 'app-toplists',
	templateUrl: './toplists.component.html',
	styleUrls: ['./toplists.component.css'],
	providers: [Description]
})
export class ToplistsComponent implements OnInit {
	private store = new Store();
	public podcasts = [];
	public amount: number;
	public categories = [];
	public category: number;
	public regions = [];
	public region: String;
	public favs: string[];
	public layout: string = "grid";

	constructor(private podcastService: PodcastService, private favService: FavouritesService, private toast: ToastService, private descriptionPipe: Description) { }

	ngOnInit() {
		this.amount = 50;
		this.categories = this.podcastService.getCategories();
		this.category = 26;
		this.regions = this.podcastService.getRegions();
		this.region = this.store.get("region", "us") as string;
		this.getPodcasts();
		this.layout = this.store.get("layout", "grid") as string;
		this.favService.favouriteTitles.subscribe(value => {
			this.favs = value;
		});
	}

	getPodcasts = () => {
		this.podcastService.getToplist(this.region, this.category, this.amount).subscribe((data) => {
			this.podcasts = data['feed']['entry'];
		});
	}

	addPodcast(id): void {
		this.favService.addItunesFavourite(id);
	}

	showDescription(description): void {
		this.toast.modal("Episode description", this.descriptionPipe.transform(description));
	}

	isFavourite = (title) => {
		return this.favs.indexOf(title) !== -1;
	};
}
