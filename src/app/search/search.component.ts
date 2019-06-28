import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit {
  query: String;
  results: Array<Object>;
  favs: string[];

  constructor(private podcasts: PodcastService, private favService: FavouritesService) { }

  ngOnInit() {
    document.getElementById("search").focus();
    this.favService.favouriteTitles.subscribe(value => { this.favs = value});
  }

  search = () => {
    this.podcasts.search(this.query).subscribe((data) => {
      this.results = data.results;
    });
  }

  addToFavourites = (rss) => {
    this.favService.addFavourite(rss);
  }

}
