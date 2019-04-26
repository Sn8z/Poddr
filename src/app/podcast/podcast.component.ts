import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AudioService } from '../services/audio.service';
import { ToastService } from '../services/toast.service';
import { PodcastService } from '../services/podcast.service';
import * as parsePodcast from 'node-podcast-parser';
import * as log from 'electron-log';

@Component({
  selector: 'app-podcast',
  templateUrl: './podcast.component.html',
  styleUrls: ['./podcast.component.css']
})
export class PodcastComponent implements OnInit {
  private id: string;
  private regPattern: RegExp = /^[0-9]+$/;

  rss: String;
  title: String;
  author: String;
  description: String;
  image: String;
  updated: String;
  website: String;
  email: String;
  episodes: Array<any>;
  latestEpisode: any;

  constructor(private route: ActivatedRoute, private audio: AudioService, private toast: ToastService, private podcastService: PodcastService) { }

  ngOnInit() {
    this.id = this.route.snapshot.params['id'];
    if (this.regPattern.test(this.id)) {
      this.getRSS(this.id);
    } else {
      this.parseRSS(this.id);
    }
  }

  //Extra step needed if we only have the iTunes ID
  private getRSS(id: String): void {
    this.podcastService.getRssFeed(id).subscribe((data) => {
      this.parseRSS(data['results'][0]['feedUrl']);
    });
  }

  private parseRSS(rss: String): void {
    this.rss = rss;
    this.podcastService.getPodcastFeed(rss).subscribe((response) => {
      parsePodcast(response, (error, data) => {
        if(error){
          console.log(error);
        } else {
          log.info(data);
          this.title = data.title;
          this.author = data.author;
          this.description = data.description.long;
          this.image = data.image;
          this.updated = data.updated;
          this.website = data.link;
          this.email = data.owner.email;
          this.episodes = data.episodes;
          this.latestEpisode = this.episodes[0];
        }
      });
    });
  }

  play(podcastObject: any): void {
    console.log(podcastObject);
    let podcast = {
      src: podcastObject.enclosure.url,
      episodeTitle: podcastObject.title,
      description: podcastObject.description,
      guid: podcastObject.guid,
      cover: podcastObject.image
    };
    this.audio.loadAudio(podcast, this.title, this.rss, this.image);
    this.audio.play();
  }

  pause(): void {
    this.audio.pause();
  }
}
