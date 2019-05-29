import { Component, OnInit } from '@angular/core';
import { HotkeysService } from './services/hotkeys.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit{
  constructor(private hotkeys: HotkeysService) { }
  
  ngOnInit() {
    // Add class to body when the mouse is being used
    // These functions work together with CSS :focus on different elements
    document.body.addEventListener('mousedown', function () {
      document.body.classList.add('using-mouse');
    });
    document.body.addEventListener('keydown', function () {
      document.body.classList.remove('using-mouse');
    });
  }
}
