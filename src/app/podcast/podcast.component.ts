import { Component, OnInit, NgZone } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AudioService } from '../services/audio.service';
import { PodcastService } from '../services/podcast.service';
import { PlayedService } from '../services/played.service';
import { ToastService } from '../services/toast.service';
import { Description } from '../pipes/description.pipe';
import { FavouritesService } from '../services/favourites.service';
import { OfflineService } from '../services/offline.service';
import { faHeart, faCircle, faEnvelope } from '@fortawesome/free-regular-svg-icons';
import {
	faSortAmountDown,
	faSortAmountUp,
	faInfoCircle,
	faCheckCircle,
	faDownload,
	faGlobeEurope,
	faRss,
	faEllipsisV
} from '@fortawesome/free-solid-svg-icons';
import * as parsePodcast from 'node-podcast-parser';
import * as log from 'electron-log';

@Component({
	selector: 'app-podcast',
	templateUrl: './podcast.component.html',
	styleUrls: ['./podcast.component.css'],
	providers: [Description]
})
export class PodcastComponent implements OnInit {
	private id: string;
	private regPattern: RegExp = /^[0-9]+$/;

	public faHeart = faHeart;
	public faCircle = faCircle;
	public faEnvelope = faEnvelope;
	public faSortUp = faSortAmountUp;
	public faSortDown = faSortAmountDown;
	public faInfoCircle = faInfoCircle;
	public faCheckCircle = faCheckCircle;
	public faDownload = faDownload;
	public faGlobeEurope = faGlobeEurope;
	public faRss = faRss;
	public faEllipsisV = faEllipsisV;

	public isLoading: Boolean = true;
	public rss: String;
	public title: string;
	public author: String;
	public description: String;
	public image: String;
	public updated: String;
	public website: String;
	public email: String;
	public episodes: any[];
	public allEpisodes: any[];
	public sortBy: string = "asc";
	public latestEpisode: any;
	public playedEpisodes: string[];
	public offlineEpisodes: string[];
	public query: string = "";
	public favs: string[];

	constructor(private route: ActivatedRoute,
		private audio: AudioService,
		private prevPlayed: PlayedService,
		private podcastService: PodcastService,
		private toast: ToastService,
		private favouriteService: FavouritesService,
		private offlineService: OfflineService,
		private descriptionPipe: Description,
		private zone: NgZone) { }

	ngOnInit() {
		//Listen for changes in URL parameters
		this.route.paramMap.subscribe(params => {
			this.id = params.get("id");
			if (this.regPattern.test(this.id)) {
				this.getRSS(this.id);
			} else {
				this.parseRSS(this.id);
			}
		})

		this.prevPlayed.playedEpisodes.subscribe(value => {
			this.zone.run(() => {
				this.playedEpisodes = value;
			});
		});
		this.offlineService.offlineKeys.subscribe(value => {
			this.zone.run(() => {
				this.offlineEpisodes = value;
			});
		});
		this.favouriteService.favouriteTitles.subscribe(value => {
			this.zone.run(() => {
				this.favs = value;
			});
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

	download(event, podcastObject: any): void {
		event.stopPropagation();
		this.offlineService.download(this.title, this.rss, podcastObject);
	}

	removeDownload = (event, podcastObject: any) => {
		event.stopPropagation();
		this.offlineService.remove(podcastObject.guid);
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

	showDescription(event, title, description): void {
		event.stopPropagation();
		this.toast.modal(title, this.descriptionPipe.transform(description));
	}

	addFavourite(): void {
		this.favouriteService.addFavourite(this.rss);
	}

	markAsPlayed = (guid) => {
		this.prevPlayed.markAsPlayed(guid);
	}

	unmarkAsPlayed = (guid) => {
		this.prevPlayed.unmarkAsPlayed(guid);
	}
}
