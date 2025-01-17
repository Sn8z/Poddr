import { Component, OnDestroy, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { faFire, faSearch, faTools } from '@fortawesome/free-solid-svg-icons';
import { faHeart } from '@fortawesome/free-regular-svg-icons';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-sidenav',
    templateUrl: './sidenav.component.html',
    styleUrls: ['./sidenav.component.css'],
    standalone: false
})
export class SidenavComponent implements OnInit, OnDestroy {
	private audioCoverSubscription: Subscription;
	private audioRssSubscription: Subscription;

	public image: string = '';
	public rss: string = '';

	public faFire = faFire;
	public faSearch = faSearch;
	public faTools = faTools;
	public faHeart = faHeart;

	constructor(private audio: AudioService) { }

	ngOnInit() {
		this.audioCoverSubscription = this.audio.episodeCover.subscribe(value => {
			this.image = value;
		});
		this.audioRssSubscription = this.audio.rss.subscribe(value => { this.rss = value });
	}

	ngOnDestroy() {
		if (this.audioCoverSubscription) this.audioCoverSubscription.unsubscribe();
		if (this.audioRssSubscription) this.audioRssSubscription.unsubscribe();
	}

}
