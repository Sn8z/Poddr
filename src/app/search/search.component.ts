import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit {

  constructor(private podcasts: PodcastService) { }

  ngOnInit() {
  }

  search(){
    this.podcasts.search();
  }

  error(){
    this.podcasts.s2();
  }

}
