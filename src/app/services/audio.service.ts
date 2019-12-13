import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { ToastService } from './toast.service';
import { PlayedService } from './played.service';
import * as log from 'electron-log';
import * as Store from 'electron-store';

const ipc = require('electron').ipcRenderer;

@Injectable({
	providedIn: 'root'
})
export class AudioService {
	private store = new Store();
	private audio: HTMLAudioElement = new Audio();
	private guid: string = "";

	public rss: BehaviorSubject<string> = new BehaviorSubject("");
	public loading: BehaviorSubject<boolean> = new BehaviorSubject(false);
	public playing: BehaviorSubject<boolean> = new BehaviorSubject(false);
	public muted: BehaviorSubject<boolean> = new BehaviorSubject(false);
	public podcast: BehaviorSubject<string> = new BehaviorSubject("No title");
	public episode: BehaviorSubject<string> = new BehaviorSubject("No title");
	public description: BehaviorSubject<string> = new BehaviorSubject("No description");
	public podcastCover: BehaviorSubject<string> = new BehaviorSubject("");
	public episodeCover: BehaviorSubject<string> = new BehaviorSubject("");
	public time: BehaviorSubject<number> = new BehaviorSubject(0);
	public duration: BehaviorSubject<number> = new BehaviorSubject(0);
	public percentPlayed: BehaviorSubject<number> = new BehaviorSubject(0);
	public volume: BehaviorSubject<number> = new BehaviorSubject(0);
	public playbackRate: BehaviorSubject<number> = new BehaviorSubject(1.0);

	constructor(private toast: ToastService, private played: PlayedService) {
		this.initIpcListeners();
		this.initAudio();
		this.initAudioListeners();
		log.info("Audio service :: Initialized audio service.");
	}

	private initIpcListeners(): void {
		log.info("Audio service :: Initializing IPC listeners.");
		ipc.on("player:toggle-play", () => { this.togglePlay() });
		ipc.on("app:close", () => {
			this.store.set("volume", this.audio.volume);
			this.store.set("time", this.audio.currentTime);
			this.store.set("playbackRate", this.audio.playbackRate);
			ipc.send("app:closed");
		});
	}

	private initAudio(): void {
		log.info("Audio service :: Initializing Audio.");

		//Load stored volume
		this.audio.volume = this.store.get("volume", 0.5) as number;
		this.volume.next(this.audio.volume);

		//Load stored time
		this.audio.currentTime = this.store.get("time", 0) as number;

		//Load stored playbackRate
		this.setPlaybackRate(this.store.get("playbackRate", 1.0) as number);
		this.playbackRate.next(this.audio.playbackRate);

		//Load stored playerstate
		let playerState: any = this.store.get("playerState");
		if (playerState) {
			this.audio.src = playerState.podcastURL;
			this.guid = playerState.podcastGUID;
			this.rss.next(playerState.podcastRSS);
			this.podcast.next(playerState.podcastTitle);
			this.episode.next(playerState.podcastEpisodeTitle);
			this.podcastCover.next(playerState.podcastCover);
			this.episodeCover.next(playerState.episodeCover);
			this.description.next(playerState.podcastDescription);
		}

		this.updateMedia();
	}

	private initAudioListeners(): void {
		log.info("Audio service :: Initializing Event listeners.");
		this.audio.addEventListener('play', this.onPlay);
		this.audio.addEventListener('pause', this.onPause);
		this.audio.addEventListener('loadstart', this.onLoadStart);
		this.audio.addEventListener('timeupdate', this.onTimeUpdate);
		this.audio.addEventListener('volumechange', this.onVolumeChange);
		this.audio.addEventListener('ratechange', this.onPlaybackRateChange);
		this.audio.addEventListener('seeking', this.onSeeking);
		this.audio.addEventListener('waiting', this.onWaiting);
		this.audio.addEventListener('canplaythrough', this.onCanPlayThrough);
		this.audio.addEventListener('ended', this.onEnded);
		this.audio.addEventListener('error', this.onError);
	}

	private onPlay = () => {
		log.info("Audio service :: Playing.");
		this.playing.next(true);
		ipc.send("media-play");
	}

	private onPause = () => {
		log.info("Audio service :: Paused.");
		this.playing.next(false);
		ipc.send("media-pause");
	}

	private onLoadStart = () => {
		log.info("Audio service :: Started loading.");
		this.loading.next(true);
	}

	private onTimeUpdate = () => {
		this.percentPlayed.next((this.audio.currentTime / this.audio.duration) * 100 || 0);
		this.time.next(this.audio.currentTime);
	}

	private onVolumeChange = () => {
		this.volume.next(this.audio.volume);
		this.muted.next(this.audio.volume === 0 || this.audio.muted);
	}

	private onPlaybackRateChange = () => {
		log.info("Audio service :: PlaybackRate changed to " + this.audio.playbackRate);
		this.playbackRate.next(this.audio.playbackRate);
	}

	private onSeeking = () => {
		log.info("Audio service :: Seeking.");
		this.loading.next(true);
	}

	private onWaiting = () => {
		log.info("Audio service :: Waiting for more data.");
		this.loading.next(true);
	}

	private onCanPlayThrough = () => {
		log.info("Audio service :: Can play through.");
		this.loading.next(false);
		this.duration.next(this.audio.duration);
	}

	private onEnded = () => {
		log.info("Audio service :: Podcast ended.");
		this.toast.toast("Podcast ended");
		this.played.markAsPlayed(this.guid);
	}

	private onError = (error) => {
		log.error('Audio service :: Error => ' + error.target.error.code + ' :: ' + error.target.error.message);
		log.error('Audio service :: Audio source => ' + this.audio.src);

		switch (error.target.error.code) {
			case error.target.error.MEDIA_ERR_ABORTED:
				this.toast.toastError('You aborted the playback.');
				break;
			case error.target.error.MEDIA_ERR_NETWORK:
				this.toast.toastError('A network error caused the audio download to fail.');
				break;
			case error.target.error.MEDIA_ERR_DECODE:
				this.toast.toastError('The audio playback was aborted due to an error when decoding media.');
				break;
			case error.target.error.MEDIA_ERR_SRC_NOT_SUPPORTED:
				this.toast.toastError('The audio could not be loaded, either because the server or network failed or because the format is not supported.');
				break;
			default:
				this.toast.toastError('Something went wrong, try again.');
				break;
		}

		this.loading.next(false);
	}

	private updateMedia = () => {
		ipc.send("media-update", {
			image: this.episodeCover.value,
			title: this.episode.value,
			artist: this.podcast.value
		});
	}

	// public methods
	loadAudio(podcast, pTitle, pRSS, pCover): void {
		this.audio.src = podcast.src;
		this.guid = podcast.guid;
		this.rss.next(pRSS);
		this.podcast.next(pTitle);
		this.episode.next(podcast.episodeTitle);
		this.description.next(podcast.description);
		this.duration.next(0);
		this.time.next(0);

		this.podcastCover.next(pCover);
		if (podcast.cover) {
			this.episodeCover.next(podcast.cover);
		} else {
			this.episodeCover.next(pCover);
		}

		this.store.set("playerState", {
			podcastURL: this.audio.src,
			podcastTitle: this.podcast.value,
			podcastEpisodeTitle: this.episode.value,
			podcastCover: this.podcastCover.value,
			episodeCover: this.episodeCover.value,
			podcastRSS: this.rss.value,
			podcastDescription: this.description.value,
			podcastGUID: this.guid
		});

		this.updateMedia();
	}

	play(): void {
		this.audio.play();
	}

	pause(): void {
		this.audio.pause();
	}

	togglePlay(): void {
		this.audio.paused ? this.audio.play() : this.audio.pause();
	}

	setTime(time: number): void {
		this.audio.currentTime = time;
	}

	changeTime(amount: number): void {
		this.audio.currentTime += amount;
	}

	getDuration(): number {
		return this.audio.duration;
	}

	setVolume(volume: number): void {
		this.audio.volume = volume;
	}

	changeVolume(diff: number): void {
		if (this.audio.volume + diff > 1) {
			this.audio.volume = 1;
		} else if (this.audio.volume + diff < 0) {
			this.audio.volume = 0;
		} else {
			this.audio.volume += diff;
		}
	}

	setPlaybackRate(rate: number): void {
		if (rate >= 0.25 && rate <= 2.00) {
			this.audio.playbackRate = rate;
			this.audio.defaultPlaybackRate = rate;
		}
	}

	getRSS(): string {
		return this.rss.value;
	}

	getAudio(): HTMLAudioElement {
		return this.audio;
	}
}
