import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HotkeysService } from './services/hotkeys.service';
import { ToastService } from './services/toast.service';
import * as Store from 'electron-store';
import * as log from 'electron-log';
import * as electron from 'electron';

const themesJSON = require('../assets/themes/themes.json');

@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
	private store: Store<any> = new Store();

	constructor(private hotkeys: HotkeysService, private http: HttpClient, private toast: ToastService) { }

	ngOnInit() {
		this.initFocusHandler();
		this.initTheme();
		this.initUpdateCheck();
	}

	initFocusHandler = () => {
		document.body.addEventListener('mousedown', function () {
			document.body.classList.add('using-mouse');
		});
		document.body.addEventListener('keydown', function () {
			document.body.classList.remove('using-mouse');
		});
	}

	initTheme = () => {
		const root = document.documentElement;

		//Load accent color
		const color = this.store.get("color", "#FF9900");
		root.style.setProperty('--primary-color', color);
		log.info("App setup :: Loaded CSS color variable (" + color + ").");

		//Load theme colors
		const theme = this.store.get("theme", "Dark");
		root.style.setProperty('--primary-bg-color', themesJSON.themes[theme]['primaryBackground']);
		root.style.setProperty('--secondary-bg-color', themesJSON.themes[theme]['secondaryBackground']);
		root.style.setProperty('--third-bg-color', themesJSON.themes[theme]['thirdBackground']);
		root.style.setProperty('--primary-text-color', themesJSON.themes[theme]['primaryTextColor']);
		root.style.setProperty('--secondary-text-color', themesJSON.themes[theme]['secondaryTextColor']);
		log.info("App setup :: Loaded " + theme + " theme.");
	}

	initUpdateCheck = () => {
		log.info("App setup :: Checking for updates...");
		this.http.get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json").subscribe((response) => {
			if (response['version'] != electron.remote.app.getVersion()) {
				log.info("App setup :: Found update " + response['version'] + "!");
				this.toast.toastURL(response['version'] + " is now available!", "https://github.com/Sn8z/Poddr/releases", 15000);
			} else {
				log.info("App setup :: No updates found.");
			}
		});
	}
}
