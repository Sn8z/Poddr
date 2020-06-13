import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';
import { ToastService } from '../services/toast.service';
import { Description } from '../pipes/description.pipe';
import { faInfoCircle, faTh, faList } from '@fortawesome/free-solid-svg-icons';
import * as Store from 'electron-store';
import * as parsePodcast from 'node-podcast-parser';

@Component({
  selector: 'app-latest',
  templateUrl: './latest.component.html',
  styleUrls: ['./latest.component.css'],
  providers: [Description]
})
export class LatestComponent implements OnInit {
  private store = new Store();
  public latest: Array<Object> = [];
  public layout: string = "list";

  public faInfoCircle = faInfoCircle;
  public faTh = faTh;
  public faList = faList;

  constructor(private podcastService: PodcastService,
    private favService: FavouritesService,
    private toast: ToastService,
    private descriptionPipe: Description) { }

  ngOnInit() {
    this.layout = this.store.get("layout", "grid") as string;
    this.favService.favourites.subscribe(value => {
      const latest = [];
      value.forEach(item => {
        this.podcastService.getPodcastFeed(item['rss']).subscribe((response) => {
          parsePodcast(response, (error, data) => {
            if (error) {
              console.log('Latest Episode :: ' + error);
              this.toast.toastError("Something went wrong when fetching latest episodes.");
            } else {
              const episode = data.episodes[0];
              episode['podcastImage'] = data.image;
              episode['podcastTitle'] = data.title;
              episode['rss'] = item['rss'];
              latest.push(episode);
            }
          });
        });
      });
      this.latest = latest;
    });
  }

  showDescription(title, description): void {
    this.toast.modal(title, this.descriptionPipe.transform(description));
  }

}
