import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HotkeysService } from './services/hotkeys.service';
import { ToastService } from './services/toast.service';
import Store from 'electron-store';
import * as log from 'electron-log';
import { Router, NavigationStart, NavigationEnd, RouterEvent } from '@angular/router';
import { filter } from 'rxjs/operators';
import { ipcRenderer } from 'electron';
import { gt } from 'semver';

const themesJSON = require('../assets/themes/themes.json');

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.css'],
    standalone: false
})

export class AppComponent implements OnInit {
	private positions: Object = {};
	private store: Store<any> = new Store();

	constructor(private hotkeys: HotkeysService, private http: HttpClient, private toast: ToastService, private router: Router) { }

	ngOnInit() {
		this.initScrollStateSaver();
		this.initFocusHandler();
		this.initTheme();
		this.initUpdateCheck();
	}

	initScrollStateSaver = () => {
		const contentRouter = document.getElementById('content-router');
		this.router.events.pipe(
			filter((event) => event instanceof NavigationStart || event instanceof NavigationEnd)).subscribe((event) => {
				if (event instanceof NavigationStart) {
					this.positions[event.id] = {
						trigger: event.navigationTrigger || '',
						position: contentRouter.scrollTop || 0,
						restoreID: event.restoredState ? event.restoredState.navigationId + 1 || '' : ''
					}
				} else if (event instanceof NavigationEnd) {
					if (this.positions[event.id].trigger === 'imperative') {
						contentRouter.scrollTop = 0;
					} else if (this.positions[event.id].trigger === 'popstate') {
						const scrollPos = this.positions[this.positions[event.id].restoreID].position || 0;
						setTimeout(() => contentRouter.scrollTop = scrollPos, 100);
					}
				}
			});
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
		ipcRenderer.invoke('appVersion').then((appVersion) => {
			this.http.get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json").subscribe((response) => {
				if (gt(response['version'], appVersion)) {
					log.info("App setup :: Found update " + response['version'] + "!");
					this.toast.toastURL(response['version'] + " is now available!", "https://github.com/Sn8z/Poddr/releases", 15000);
				} else {
					log.info("App setup :: No updates found. You are running Poddr " + appVersion);
				}
			});
		});
	}
}
