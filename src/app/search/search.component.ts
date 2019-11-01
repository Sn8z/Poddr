import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';
import { ActivatedRoute, Router } from '@angular/router';
import { faHeart } from '@fortawesome/free-regular-svg-icons';

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

	public faHeart = faHeart;

	constructor(private route: ActivatedRoute, private router: Router, private podcasts: PodcastService, private favService: FavouritesService) { }

	ngOnInit() {
		document.getElementById("search").focus();

		//Listen for changes in URL parameters
		this.route.paramMap.subscribe(params => {
			this.query = params.get("query");
			if (this.query) {
				this.search();
			} else {
				this.results = [];
				this.isEmpty = false;
			}
		})

		this.favService.favouriteTitles.subscribe(value => { this.favs = value });
	}

	searchNavigation = () => {
		this.router.navigate(['/search', { query: this.query }]);
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
