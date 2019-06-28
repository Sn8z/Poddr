import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { ToastService } from '../services/toast.service';
import { Description } from '../pipes/description.pipe';
import { FavouritesService } from '../services/favourites.service';

@Component({
  selector: 'app-player',
  templateUrl: './player.component.html',
  styleUrls: ['./player.component.css'],
  providers: [Description]
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
  description: string;
  favs: string[];

  constructor(private audio: AudioService,
    private toast: ToastService,
    private descriptionPipe: Description,
    private favService: FavouritesService) { }

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
    this.audio.description.subscribe(value => { this.description = value });
    this.favService.favouriteTitles.subscribe(value => { this.favs = value});
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

  showDescription(): void {
    this.toast.modal("Podcast description", this.descriptionPipe.transform(this.description));
  }

  addPodcast = () => {
    this.favService.addFavourite(this.audio.getRSS());
  }
}
