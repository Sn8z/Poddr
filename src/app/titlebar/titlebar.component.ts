import { Component, OnInit } from "@angular/core";
import { ipcRenderer as ipc } from 'electron';
import { Location } from '@angular/common';
import { faTimes, faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
import { faWindowMinimize, faSquare } from '@fortawesome/free-regular-svg-icons';

@Component({
    selector: "app-titlebar",
    templateUrl: "./titlebar.component.html",
    styleUrls: ["./titlebar.component.css"],
    standalone: false
})
export class TitlebarComponent implements OnInit {
	public faWindowMinimize = faWindowMinimize;
	public faSquare = faSquare;
	public faTimes = faTimes;
	public faChevronLeft = faChevronLeft;
	public faChevronRight = faChevronRight;

	constructor(private location: Location) { }

	ngOnInit() { }

	public goBack() {
		this.location.back();
	}

	public goForward() {
		this.location.forward();
	}

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
