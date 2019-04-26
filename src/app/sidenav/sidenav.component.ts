import { Component, OnInit } from '@angular/core';
import { AudioService } from '../services/audio.service';

@Component({
  selector: 'app-sidenav',
  templateUrl: './sidenav.component.html',
  styleUrls: ['./sidenav.component.css']
})
export class SidenavComponent implements OnInit {
  public image: string = "";

  constructor(private audio: AudioService) { }

  ngOnInit() {
    this.audio.episodeCover.subscribe(value => {
      this.image = value;
    });
  }

}
