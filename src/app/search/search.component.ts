import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit {
  query: String;
  results: Array<Object>;

  constructor(private podcasts: PodcastService) { }

  ngOnInit() {
    document.getElementById("search").focus();
  }

  search(){
    this.podcasts.search(this.query).subscribe((data) => {
      console.log(data);
      this.results = data.results;
    });
  }

}
