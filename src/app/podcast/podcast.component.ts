import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AudioService } from '../services/audio.service';
import { PodcastService } from '../services/podcast.service';
import { PlayedService } from '../services/played.service';
import { ToastService } from '../services/toast.service';
import { Description } from '../pipes/description.pipe';
import * as parsePodcast from 'node-podcast-parser';
import * as log from 'electron-log';
import { FavouritesService } from '../services/favourites.service';

@Component({
	selector: 'app-podcast',
	templateUrl: './podcast.component.html',
	styleUrls: ['./podcast.component.css'],
	providers: [Description]
})
export class PodcastComponent implements OnInit {
	private id: string;
	private regPattern: RegExp = /^[0-9]+$/;

	isLoading: Boolean = true;
	rss: String;
	title: string;
	author: String;
	description: String;
	image: String;
	updated: String;
	website: String;
	email: String;
	episodes: any[];
	allEpisodes: any[];
	sortBy: string = "asc";
	latestEpisode: any;
	playedEpisodes: string[];
	query: string = "";
	favs: string[];

	constructor(private route: ActivatedRoute,
		private audio: AudioService,
		private prevPlayed: PlayedService,
		private podcastService: PodcastService,
		private toast: ToastService,
		private favouriteService: FavouritesService,
		private descriptionPipe: Description) {
		this.prevPlayed.playedEpisodes.subscribe(value => {
			this.playedEpisodes = value;
		});
	}

	ngOnInit() {
		this.id = this.route.snapshot.params['id'];
		if (this.regPattern.test(this.id)) {
			this.getRSS(this.id);
		} else {
			this.parseRSS(this.id);
		}
		this.favouriteService.favouriteTitles.subscribe(value => {
			this.favs = value;
		});
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
				if (error) {
					console.log(error);
					this.isLoading = false;
					//Error toast
				} else {
					this.title = data.title;
					this.author = data.author;
					this.description = data.description.long;
					this.image = data.image;
					this.updated = data.updated;
					this.website = data.link;
					this.email = data.owner.email;
					this.episodes = data.episodes;
					this.allEpisodes = this.episodes.map(x => Object.assign({}, x));
					this.latestEpisode = this.episodes[0];
					this.isLoading = false;
				}
			});
		});
	}

	play(podcastObject: any): void {
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

	filter(): void {
		log.info("Filtering based on: " + this.query);
		this.episodes = this.allEpisodes.filter(e => e.description.toLowerCase().includes(this.query.toLowerCase()) || e.title.toLowerCase().includes(this.query.toLowerCase()));
	}

	toggleOrder(): void {
		log.info("Toggle " + this.sortBy);
		if (this.sortBy == "asc") {
			this.episodes.sort((x, y) => x.published - y.published);
			this.sortBy = "desc";
		} else {
			this.episodes.sort((x, y) => y.published - x.published);
			this.sortBy = "asc";
		}
	}

	showInfo(title, info): void {
		this.toast.modal(title, info);
	}

	showDescription(event, description): void {
		event.stopPropagation();
		this.toast.modal("Episode description", this.descriptionPipe.transform(description));
	}

	addFavourite(): void {
		this.favouriteService.addFavourite(this.rss);
	}
}
