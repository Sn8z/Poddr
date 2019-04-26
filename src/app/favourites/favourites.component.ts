import { Component, OnInit } from '@angular/core';
import { FavouritesService } from '../services/favourites.service';
import * as log from 'electron-log';

@Component({
  selector: 'app-favourites',
  templateUrl: './favourites.component.html',
  styleUrls: ['./favourites.component.css']
})
export class FavouritesComponent implements OnInit {
  favourites: Object;
  test: string = "Testing...";

  constructor(private favService: FavouritesService) { }

  ngOnInit() {
    this.favService.favourites.subscribe(value => {
      this.favourites = value;
      log.info(value);
    });
  }

}
