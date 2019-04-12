import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-podcast',
  templateUrl: './podcast.component.html',
  styleUrls: ['./podcast.component.css']
})
export class PodcastComponent implements OnInit {
	id: Number;

  constructor(private route: ActivatedRoute) { }

  ngOnInit() {
		this.id = this.route.snapshot.params['id'];
	}

}
