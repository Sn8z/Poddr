import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-toplists',
  templateUrl: './toplists.component.html',
  styleUrls: ['./toplists.component.css']
})
export class ToplistsComponent implements OnInit {
  amount = 50;
  
  constructor() { }

  ngOnInit() {
  }

}
