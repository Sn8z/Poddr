import { Component, OnInit } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import * as Store from 'electron-store';
import * as log from 'electron-log';
import Pickr from '@simonwep/pickr';
import * as app from 'electron';

@Component({
	selector: 'app-settings',
	templateUrl: './settings.component.html',
	styleUrls: ['./settings.component.css']
})
export class SettingsComponent implements OnInit {
	private store: Store<any> = new Store();

	public regions: string[] = [];
	public region: string = "";
	public layout: string = "";
	public modKey: string = process.platform == "darwin" ? "Cmd" : "Ctrl";

	public appVersion: string = app.remote.app.getVersion();
	public appStorage: string = app.remote.app.getPath('userData');
	public electronVersion: string = process.versions.electron;

	constructor(private podcastService: PodcastService) { }

	ngOnInit() {
		this.regions = this.podcastService.getRegions();
		this.region = this.store.get("region", "us");
		this.layout = this.store.get("layout", "grid");
		this.initPickr();
	}

	private initPickr = () => {
		const pickr = new Pickr({
			el: '.clr-pickr',
			default: '#00FFAA',
			theme: 'classic',
			lockOpacity: true,
			components: {
				preview: true,
				opacity: true,
				hue: true,
				interaction: {
					save: true
				}
			}
		});
		pickr.on('init', instance => {
			pickr.setColor(this.store.get("color", "#FF9900"));
		}).on('save', (color, instance) => {
			this.setColor(color.toHEXA().toString());
		});
	}

	setRegion = () => {
		this.store.set("region", this.region);
		log.info("Setting default region to: " + this.region);
	}

	setLayout = () => {
		this.store.set("layout", this.layout);
		log.info("Setting default layout to: " + this.layout);
	}

	setColor = (color) => {
		const html = document.getElementsByTagName("html")[0];
		html.style.cssText = "--primary-color: " + color;
		this.store.set("color", color);
		log.info("Color set to " + color);
	}

	//restart
	//open devtools
	//open URL
}
