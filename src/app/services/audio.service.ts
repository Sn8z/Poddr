import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import * as log from 'electron-log';
import * as Store from 'electron-store';
import { ToastService } from './toast.service';
const ipc = require('electron').ipcRenderer;

@Injectable({
	providedIn: 'root'
})
export class AudioService {
	private store = new Store();
	private audio: HTMLAudioElement = new Audio();
	private rss: string = "";
	private guid: string = "";

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

	constructor(private toast: ToastService) {
		log.info("Initializing audio service");
		this.initIpcListeners();
		this.initAudio();
		this.initAudioListeners();
		log.info("Initializing audio service - Done!");
	}

	private initIpcListeners(): void {
		log.info("Initializing audio service - IPC listeners");
		ipc.on("player:toggle-play", () => { this.togglePlay() });
	}

	private initAudio(): void {
		log.info("Initializing audio service - Audio");

		this.audio.volume = this.store.get("volume", 0.5) as number;
		this.volume.next(this.audio.volume);

		let playerState: any = this.store.get("playerState");
		if (playerState) {
			this.audio.src = playerState.podcastURL;
			this.rss = playerState.podcastRSS;
			this.guid = playerState.podcastGUID;
			this.podcast.next(playerState.podcastTitle);
			this.episode.next(playerState.podcastEpisodeTitle);
			this.podcastCover.next(playerState.podcastCover);
			this.episodeCover.next(playerState.episodeCover);
			this.description.next(playerState.podcastDescription);
		}

		this.updateMedia();
	}

	private initAudioListeners(): void {
		log.info("Initializing audio service - Event listeners");
		this.audio.addEventListener('play', this.onPlay);
		this.audio.addEventListener('pause', this.onPause);
		this.audio.addEventListener('loadstart', this.onLoadStart);
		this.audio.addEventListener('timeupdate', this.onTimeUpdate);
		this.audio.addEventListener('volumechange', this.onVolumeChange);
		this.audio.addEventListener('seeking', this.onSeeking);
		this.audio.addEventListener('canplaythrough', this.onCanPlayThrough);
		this.audio.addEventListener('ended', this.onEnded);
		this.audio.addEventListener('error', this.onError);
	}

	private onPlay = () => {
		log.info("Playing");
		this.playing.next(true);
		ipc.send("media-play");
	}

	private onPause = () => {
		log.info("Paused");
		this.playing.next(false);
		ipc.send("media-pause");
	}

	private onLoadStart = () => {
		log.info("Started loading");
		this.loading.next(true);
	}

	private onTimeUpdate = () => {
		this.percentPlayed.next((this.audio.currentTime / this.audio.duration) * 100 || 0);
		this.time.next(this.audio.currentTime);
	}

	private onVolumeChange = () => {
		log.info("Changed volume");
		this.volume.next(this.audio.volume);
		this.muted.next(this.audio.volume === 0 || this.audio.muted);
		this.store.set("volume", this.audio.volume); // debounce this call to avoid hogging to much power
	}

	private onSeeking = () => {
		log.info("Seeking");
		this.loading.next(true);
	}

	private onCanPlayThrough = () => {
		log.info("Can play through");
		this.loading.next(false);
		this.duration.next(this.audio.duration);
	}

	private onEnded = () => {
		log.info("Podcast ended.");
		this.toast.info("Podcast ended");
		// Add episode to previously played episodes
	}

	private onError = (e) => {
		log.error(e.target.error.message);
		this.toast.error("Something went wrong");
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
		this.rss = pRSS;
		this.guid = podcast.guid;
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
			podcastRSS: this.rss,
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

	getAudio(): HTMLAudioElement {
		return this.audio;
	}
}
