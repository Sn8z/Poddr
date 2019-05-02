import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { PodcastService } from './podcast.service';
import * as Store from 'electron-store';
import * as parsePodcast from 'node-podcast-parser';
import * as log from 'electron-log';
import { ToastService } from './toast.service';


@Injectable({
  providedIn: 'root'
})
export class FavouritesService {
  private store: Store = new Store({ name: "favourites" });

  favourites: BehaviorSubject<Object[]> = new BehaviorSubject<Object[]>([]);
  favouriteKeys: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);

  constructor(private podcastService: PodcastService, private toast: ToastService) {
    this.updateFavourites();
  }

  private updateFavourites(): void {
    this.favourites.next(Object.values(this.store.store) as Object[]);
    this.favouriteKeys.next(Object.keys(this.store.store) as string[]);
  }

  //addItunesFavourite
  addItunesFavourite = (id) => {
    this.podcastService.getRssFeed(id).subscribe((data) => {
      this.addFavourite(data['results'][0]['feedUrl']);
    });
  }

  //addFavourite
  addFavourite = (rss) => {
    this.podcastService.getPodcastFeed(rss).subscribe((response) => {
      parsePodcast(response, (error, data) => {
        if (error) {
          log.error(error);
        } else {
          this.store.set(rss.replace(/\./g, '\\.'), {
            rss: rss,
            title: data.title,
            img: data.image,
            dateAdded: Date.now()
          });
          this.toast.message("Added " + data.title + " to favourites!");
          log.info("Added " + data.title + " to favourites.");
        }
      })
    });
    this.updateFavourites();
  }

  removeFavourite = (rss) => {
    this.store.delete(rss.replace(/\./g, '\\.'));
    log.info("Removed " + rss + " from favourites.");
    this.updateFavourites();
  }
}
