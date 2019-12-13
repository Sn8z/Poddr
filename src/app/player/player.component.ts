import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { ToastService } from '../services/toast.service';
import { Description } from '../pipes/description.pipe';
import { FavouritesService } from '../services/favourites.service';
import { faPlayCircle, faPauseCircle, faHeart } from '@fortawesome/free-regular-svg-icons';
import { faBackward, faForward, faInfoCircle } from '@fortawesome/free-solid-svg-icons';

@Component({
	selector: 'app-player',
	templateUrl: './player.component.html',
	styleUrls: ['./player.component.css'],
	providers: [Description]
})
export class PlayerComponent implements OnInit {
	public faPlayCircle = faPlayCircle;
	public faPauseCircle = faPauseCircle;
	public faHeart = faHeart;
	public faBackward = faBackward;
	public faForward = faForward;
	public faInfoCircle = faInfoCircle;

	public volume: number;
	public percentPlayed: number;
	public isLoading: boolean = false;
	public isPlaying: boolean = false;
	public isMuted: boolean = false;
	public duration: number = 0;
	public time: number = 0;
	public podcast: string;
	public episode: string;
	public description: string;
	public rss: string;
	public playbackRates: number[] = [2.00, 1.75, 1.50, 1.25, 1.00, 0.75, 0.50, 0.25];
	public playbackRate: number;
	public favs: string[];

	constructor(private audio: AudioService,
		private toast: ToastService,
		private descriptionPipe: Description,
		private favService: FavouritesService) { }

	ngOnInit(): void {
		this.audio.loading.subscribe(value => { this.isLoading = value; });
		this.audio.playing.subscribe(value => { this.isPlaying = value });
		this.audio.muted.subscribe(value => { this.isMuted = value });
		this.audio.volume.subscribe(value => { this.volume = value; });
		this.audio.percentPlayed.subscribe(value => { this.percentPlayed = value; });
		this.audio.time.subscribe(value => { this.time = value });
		this.audio.duration.subscribe(value => { this.duration = value });
		this.audio.episode.subscribe(value => { this.episode = value });
		this.audio.podcast.subscribe(value => { this.podcast = value });
		this.audio.description.subscribe(value => { this.description = value });
		this.audio.rss.subscribe(value => { this.rss = value });
		this.audio.playbackRate.subscribe(value => { this.playbackRate = value});
		this.favService.favouriteTitles.subscribe(value => { this.favs = value });
	}

	togglePlay(): void {
		this.audio.togglePlay();
	};

	changeTime(change: number): void {
		this.audio.changeTime(change);
	}

	setTime(event: MouseEvent): void {
		let progress = document.getElementById("progress");
		let clickX = event.clientX - progress.getBoundingClientRect().left;
		let progressWidth = progress.offsetWidth;
		let time = ((clickX / progressWidth) * this.audio.getDuration()) || 0;
		this.audio.setTime(time);
	}

	updateVolume(): void {
		this.audio.setVolume(this.volume);
	}

	setPlaybackRate(rate: number): void {
		this.audio.setPlaybackRate(rate);
	}

	showDescription(): void {
		this.toast.modal("Podcast description", this.descriptionPipe.transform(this.description));
	}

	addPodcast = () => {
		this.favService.addFavourite(this.audio.getRSS());
	}
}
