import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';
import { faFire, faSearch, faTools } from '@fortawesome/free-solid-svg-icons';
import { faHeart } from '@fortawesome/free-regular-svg-icons';

@Component({
  selector: 'app-sidenav',
  templateUrl: './sidenav.component.html',
  styleUrls: ['./sidenav.component.css']
})
export class SidenavComponent implements OnInit {
  public image: string = "";
  public rss: string;
	
	public faFire = faFire;
	public faSearch = faSearch;
	public faTools = faTools;
	public faHeart = faHeart;

  constructor(private audio: AudioService) { }

  ngOnInit() {
    this.audio.episodeCover.subscribe(value => {
      this.image = value;
    });
    this.audio.rss.subscribe(value => { this.rss = value });
  }

}
