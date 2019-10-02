import { Component, OnInit } from "@angular/core";
import { ipcRenderer as ipc } from 'electron';
import { Location } from '@angular/common';

@Component({
	selector: "app-titlebar",
	templateUrl: "./titlebar.component.html",
	styleUrls: ["./titlebar.component.css"]
})
export class TitlebarComponent implements OnInit {

	constructor(private location: Location) { }

	ngOnInit() { }

	public minimize() {
		ipc.send("window-update", "minimize");
	}

	public maximize() {
		ipc.send("window-update", "maximize");
	}

	public close() {
		ipc.send("window-update", "close");
	}
}
