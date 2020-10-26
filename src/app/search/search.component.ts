import { Component, OnDestroy, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';
import { ActivatedRoute, Router } from '@angular/router';
import { faHeart } from '@fortawesome/free-regular-svg-icons';
import { Subscription } from 'rxjs';
import * as log from 'electron-log';

@Component({
	selector: 'app-search',
	templateUrl: './search.component.html',
	styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit, OnDestroy {
	private favTitleSubscription: Subscription;
	private routeSubscription: Subscription;
	private searchSubscription: Subscription;

	public query: string = "";
	public results: Object[] = [];
	public favs: string[] = [];
	public isLoading: Boolean = false;
	public isEmpty: Boolean = false;

	public faHeart = faHeart;

	constructor(private route: ActivatedRoute, private router: Router, private podcasts: PodcastService, private favService: FavouritesService) { }

	ngOnInit() {
		document.getElementById("search").focus();

		this.favTitleSubscription = this.favService.favouriteTitles.subscribe(value => { this.favs = value });

		//Listen for changes in URL parameters
		this.routeSubscription = this.route.paramMap.subscribe(params => {
			this.query = params.get("query");
			if (this.query) {
				this.search();
			} else {
				this.results = [];
				this.isEmpty = false;
			}
		})
	}

	ngOnDestroy() {
		if (this.favTitleSubscription) this.favTitleSubscription.unsubscribe();
		if (this.routeSubscription) this.routeSubscription.unsubscribe();
		if (this.searchSubscription) this.searchSubscription.unsubscribe();
	}

	searchNavigation = (): void => {
		this.router.navigate(['/search', { query: this.query }]);
	}

	search = (): void => {
		this.isLoading = true;
		this.isEmpty = false;
		this.results = [];
		this.searchSubscription = this.podcasts.search(this.query).subscribe((data) => {
			this.results = data.results;
			this.isLoading = false;
			if (this.results.length == 0) this.isEmpty = true;
		});
	}

	addToFavourites = (rss: string): void => {
		this.favService.addFavourite(rss);
	}

}
