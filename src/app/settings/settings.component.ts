import { Component, OnInit, OnDestroy } from '@angular/core';
import { PodcastService } from '../services/podcast.service';
import { FavouritesService } from '../services/favourites.service';
import { ToastService } from '../services/toast.service';
import { faGithub, faPatreon, faPaypal } from '@fortawesome/free-brands-svg-icons';
import { faCoffee, faFileExport, faFileImport } from '@fortawesome/free-solid-svg-icons';
import { readFile, writeFile } from 'fs';
import Pickr from '@simonwep/pickr';
import * as Store from 'electron-store';
import * as log from 'electron-log';
import * as app from 'electron';
const { dialog } = require('electron').remote;
const themesJSON = require('../../assets/themes/themes.json');

@Component({
	selector: 'app-settings',
	templateUrl: './settings.component.html',
	styleUrls: ['./settings.component.css']
})
export class SettingsComponent implements OnInit, OnDestroy {
	private store: Store<any> = new Store();
	private pickr: Pickr;

	public faGithub = faGithub;
	public faPatreon = faPatreon;
	public faPaypal = faPaypal;
	public faCoffee = faCoffee;
	public faFileExport = faFileExport;
	public faFileImport = faFileImport;

	public regions: string[] = [];
	public region: string = "";
	public layouts: Object[] = [{ label: "Grid", value: "grid" }, { label: "List", value: "list" }];
	public layout: string = "";
	public themes: string[] = [];
	public theme: string = "";
	public modKey: string = process.platform == "darwin" ? "Cmd" : "Ctrl";

	public appVersion: string = app.remote.app.getVersion();
	public appStorage: string = app.remote.app.getPath('userData');
	public logStorage: string = log.transports.file.getFile().path;
	public downloadFolder: string = app.remote.app.getPath('downloads') + '/Poddr/';

	constructor(private podcastService: PodcastService, private favService: FavouritesService, private toast: ToastService) { }

	ngOnInit() {
		this.regions = this.podcastService.getRegions();
		this.region = this.store.get("region", "us");
		this.layout = this.store.get("layout", "grid");
		this.theme = this.store.get("theme", "Dark");
		this.themes = Object.keys(themesJSON.themes);

		this.initPickr();

		log.info("Settings component :: Initialized settings.");
		log.info("Settings component :: " + JSON.stringify(process.versions));
	}

	ngOnDestroy() {
		this.pickr.destroyAndRemove();
	}

	private initPickr = () => {
		this.pickr = new Pickr({
			el: '.clr-pickr',
			default: '#00FFAA',
			theme: 'classic',
			lockOpacity: true,
			components: {
				preview: true,
				opacity: true,
				hue: true,
				interaction: {
					input: true,
					save: true
				}
			}
		});
		this.pickr.on('init', instance => {
			this.pickr.setColor(this.store.get("color", "#FF9900"));
		}).on('save', (color, instance) => {
			this.setColor(color.toHEXA().toString());
		});
	}

	setRegion = () => {
		this.store.set("region", this.region);
		log.info("Settings component :: Setting default region to: " + this.region);
	}

	setLayout = () => {
		this.store.set("layout", this.layout);
		log.info("Settings component :: Setting default layout to: " + this.layout);
	}

	setTheme = () => {
		const root = document.documentElement;
		root.style.setProperty('--primary-bg-color', themesJSON.themes[this.theme]['primaryBackground']);
		root.style.setProperty('--secondary-bg-color', themesJSON.themes[this.theme]['secondaryBackground']);
		root.style.setProperty('--third-bg-color', themesJSON.themes[this.theme]['thirdBackground']);
		root.style.setProperty('--primary-text-color', themesJSON.themes[this.theme]['primaryTextColor']);
		root.style.setProperty('--secondary-text-color', themesJSON.themes[this.theme]['secondaryTextColor']);
		this.store.set("theme", this.theme);
		log.info("Settings component :: Setting theme to: " + this.theme);
	}

	setColor = (color) => {
		const root = document.documentElement;
		root.style.setProperty('--primary-color', color);
		this.store.set("color", color);
		log.info("Settings component :: Color set to " + color);
	}

	openURL = (url) => {
		log.info(url);
		try {
			app.shell.openExternal(url);
		} catch (error) {
			log.error("Settings component :: " + error);
		}
	}

	importOPML = () => {
		log.info('Settings component :: Opening OPML selection');
		const filepath = dialog.showOpenDialog({
			buttonLabel: "Import OPML file",
			filters: [
				{ name: 'OPML', extensions: ['opml', 'xml'] }
			],
			properties: ['showHiddenFiles', 'openFile']
		});
		if (filepath) {
			log.info('Settings component :: Reading OPML file ' + filepath);
			this.readOPML(filepath[0]);
		} else {
			log.error('Settings component :: No valid OPML file was selected');
		}
	}

	private readOPML = (filepath) => {
		readFile(filepath, 'utf8', (error, data) => {
			if (error) {
				log.error('Settings component :: Something went wrong when trying to open ' + filepath);
				log.error(error);
			} else {
				const parser = new DOMParser();
				const opmlDoc = parser.parseFromString(data, "text/xml");
				if (opmlDoc.documentElement.nodeName == 'parsererror') {
					log.error('Settings component :: An error occured while parsing ' + filepath);
					this.toast.toastError('An error occured while parsing ' + filepath);
				} else {
					log.info('Settings component :: Starting import of OPML favourites');
					Array.from(opmlDoc.getElementsByTagName('outline')).forEach((opmlFav) => {
						log.info(opmlFav.getAttribute('xmlUrl'));
						this.favService.addFavourite(opmlFav.getAttribute('xmlUrl'), true);
					});
					log.info('Settings component :: Done importing favourites from OPML file');
				}
			}
		});
	}

	exportOPML = () => {
		log.info('Settings component :: Creating and saving OPML file');
		const options = {
			buttonLabel: "Save OPML file",
			filters: [
				{ name: 'OPML', extensions: ['opml', 'xml'] }
			],
			properties: ['showHiddenFiles']
		}
		const filepath = dialog.showSaveDialog(options);
		if (filepath) {
			log.info('Settings component :: Saving file as' + filepath);
			const domParser = new DOMParser();
			const xmlString = "<opml version='2.0'></opml>";
			const xmlDoc = domParser.parseFromString(xmlString, "text/xml");
			const root = xmlDoc.getElementsByTagName('opml')[0];
			const headNode = xmlDoc.createElement("head");
			const titleNode = xmlDoc.createElement("title");
			titleNode.innerHTML = "Poddr Favourites";
			headNode.appendChild(titleNode);
			const bodyNode = xmlDoc.createElement("body");
			root.appendChild(headNode);
			root.appendChild(bodyNode);

			this.favService.favourites.getValue().forEach((fav) => {
				const newNode = xmlDoc.createElement("outline");
				newNode.setAttribute("text", fav['title']);
				newNode.setAttribute("type", 'rss');
				newNode.setAttribute("xmlUrl", fav['rss']);
				bodyNode.appendChild(newNode);
			});

			const serializer = new XMLSerializer();
			writeFile(filepath, serializer.serializeToString(xmlDoc), (error) => {
				if (error) {
					log.error(error);
				} else {
					log.info("Settings component :: Done creating OPML file at " + filepath);
					this.toast.toastSuccess("Done exporting OPML file!");
				}
			});
		} else {
			log.error('Settings component :: No filepath specified');
		}
	}

	restart = () => {
		log.info("Settings component :: Restarting Poddr.");
		app.remote.app.relaunch();
		app.remote.app.exit(0);
	}

	openDevTools = () => {
		log.info("Settings component :: Opening DevTools.");
		app.remote.getCurrentWindow().webContents.openDevTools();
	}
}
