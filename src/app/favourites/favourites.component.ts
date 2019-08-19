import { Component, OnInit } from '@angular/core';
import { FavouritesService } from '../services/favourites.service';
import { ToastService } from '../services/toast.service';
import * as log from 'electron-log';

@Component({
  selector: 'app-favourites',
  templateUrl: './favourites.component.html',
  styleUrls: ['./favourites.component.css']
})
export class FavouritesComponent implements OnInit {
  favourites: Object;

  constructor(private favService: FavouritesService, private toast: ToastService) { }

  ngOnInit() {
    this.favService.favourites.subscribe(value => {
			this.favourites = value;
    });
	}
	
	remove = (rss) => {
		this.favService.removeFavourite(rss);
	}

	add = () => {
		this.toast.inputRSSModal().then(x => this.favService.addFavourite(x.value));
	}

}
