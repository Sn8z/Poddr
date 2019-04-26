import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import * as Store from 'electron-store';

@Component({
	selector: 'app-toplists',
	templateUrl: './toplists.component.html',
	styleUrls: ['./toplists.component.css']
})
export class ToplistsComponent implements OnInit {
	store = new Store();
	podcasts = [];
	amount: number;
	categories = [];
	category: number;
	regions = [];
	region: String;

	constructor(private podcastService: PodcastService) { }

	ngOnInit() {
		this.amount = 50;

		this.categories = this.podcastService.getCategories();
		this.category = 26;

		this.regions = this.podcastService.getRegions();
		this.region = this.store.get("region", "us");

		this.getPodcasts();
	}

	getPodcasts() {
		this.podcastService.getToplist(this.region, this.category, this.amount).subscribe((data) => {
			this.podcasts = data['feed']['entry']
		});
	}

}
