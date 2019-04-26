import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';

@Component({
  selector: 'app-player',
  templateUrl: './player.component.html',
  styleUrls: ['./player.component.css']
})
export class PlayerComponent implements OnInit {
  volume: number;
  percentPlayed: number;
  isLoading: boolean = false;
  isPlaying: boolean = false;
  isMuted: boolean = false;
  duration: number = 0;
  time: number = 0;
  podcast: string;
  episode: string;

  constructor(private audio: AudioService) { }

  ngOnInit() {
    this.audio.loading.subscribe(value => { this.isLoading = value; });
    this.audio.playing.subscribe(value => { this.isPlaying = value });
    this.audio.muted.subscribe(value => { this.isMuted = value });
    this.audio.volume.subscribe(value => { this.volume = value; });
    this.audio.percentPlayed.subscribe(value => { this.percentPlayed = value; });
    this.audio.time.subscribe(value => { this.time = value });
    this.audio.duration.subscribe(value => { this.duration = value });
    this.audio.episode.subscribe(value => { this.episode = value });
    this.audio.podcast.subscribe(value => { this.podcast = value });
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
    console.log(clickX + " : " + progressWidth + " : " + time);
    this.audio.setTime(time);
  }

  updateVolume(): void {
    this.audio.setVolume(this.volume);
  }
}
