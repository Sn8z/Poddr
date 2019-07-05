import { Component, OnInit } from '@angular/core';
import { HotkeysService } from './services/hotkeys.service';
import * as Store from 'electron-store';
import * as log from 'electron-log';

@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
	private store: Store<any> = new Store();

	constructor(private hotkeys: HotkeysService) { }

	ngOnInit() {
		this.initFocusHandler();
		this.initTheme();
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
}
