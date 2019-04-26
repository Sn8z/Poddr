import { Injectable } from '@angular/core';
import * as Store from 'electron-store';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FavouritesService {
  private store: Store = new Store({ name: "favourites" });

  favourites: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);

  constructor() { 
    this.updateFavourites();
  }

  private updateFavourites(): void {
    this.favourites.next(Object.values(this.store.store));
  }

}
