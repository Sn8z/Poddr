import { Injectable, OnInit } from '@angular/core';
import * as log from 'electron-log';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
	providedIn: 'root'
})
export class AudioService implements OnInit {
	private audio: HTMLAudioElement;
	private loading: BehaviorSubject<boolean> = new BehaviorSubject(false);

	constructor() { }

	ngOnInit() {
		this.initIpcListeners();
		this.initAudio();
		this.initAudioListeners();
	}

	private initIpcListeners(): void {
		// Listen for IPC events from main process
	}

	private initAudio(): void {
		this.audio = new Audio();
		this.audio.volume = 0.5;
	}

	private initAudioListeners(): void {
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

	private onPlay(): void {
		log.info("Playing");
		// mpris update
	}

	private onPause(): void {
		log.info("Paused");
		// mpris update
	}

	private onLoadStart(): void {
		log.info("Started loading");
		// show loading indicator
	}

	private onTimeUpdate(): void {
		// update progress bar
	}

	private onVolumeChange(): void {
		log.info("Changed volume");
		// store volume
		// debounce this call to avoid hogging to much power
	}

	private onSeeking(): void {
		log.info("Seeking");
		// show loading indicator
	}

	private onCanPlayThrough(): void {
		log.info("Can play through");
		// Hide loading indicator
	}

	private onEnded(): void {
		log.info("Podcast ended");
		// Add episode to previously played episodes
		// toast
	}

	private onError(e): void {
		log.error(e.target.error.message);
		// toast (user friendly error)
		// Hide loading indicator
	}

	// public methods

	loadAudio(podcast: Podcast): void {
		this.audio.src = podcast.src;
		this.play();
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

	getTime(): number {
		return this.audio.currentTime;
	}

	changeVolume(amount: number): void {
		if (this.audio.volume + amount > 1) {
			this.audio.volume = 1;
		} else if (this.audio.volume + amount < 0) {
			this.audio.volume = 0;
		} else {
			this.audio.volume += amount;
		}
	}

	isPlaying(): boolean {
		return !this.audio.paused;
	}

	isLoading(): Observable<boolean> {
		return this.loading.asObservable();
	}

	isMuted(): boolean {
		return this.audio.muted || this.audio.volume === 0;
	}

	getAudio(): HTMLAudioElement {
		return this.audio;
	}
}
