import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HotkeysService } from './services/hotkeys.service';
import { ToastService } from './services/toast.service';
import * as Store from 'electron-store';
import * as log from 'electron-log';
import * as electron from 'electron';

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
		const color = this.store.get("color", "#FF9900");
		const html = document.getElementsByTagName("html")[0];
		html.style.cssText = "--primary-color: " + color;
		log.info("Loaded CSS color variable (" + color + ").");
	}

	initUpdateCheck = () => {
		log.info("Checking for updates...");
		this.http.get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json").subscribe((response) => {
			if (response['version'] != electron.remote.app.getVersion()){
				log.info("Found update " + response['version'] + "!");
				this.toast.toast(response['version'] + " is now available!", 10000);
			} else {
				log.info("No updates found!");
			}
		});
	}
}
