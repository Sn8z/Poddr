import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';

@Component({
	selector: 'app-search',
	templateUrl: './search.component.html',
	styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit {
	public query: String = "";
	public results: Object[] = [];
	public favs: string[] = [];
	public isLoading: Boolean = false;
	public isEmpty: Boolean = false;

	constructor(private podcasts: PodcastService, private favService: FavouritesService) { }

	ngOnInit() {
		document.getElementById("search").focus();
		this.favService.favouriteTitles.subscribe(value => { this.favs = value });
	}

	search = () => {
		this.isLoading = true;
		this.isEmpty = false;
		this.results = [];
		this.podcasts.search(this.query).subscribe((data) => {
			this.results = data.results;
			this.isLoading = false;
			if (this.results.length == 0) this.isEmpty = true;
		});
	}

	addToFavourites = (rss) => {
		this.favService.addFavourite(rss);
	}

}
