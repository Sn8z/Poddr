import { Injectable } from '@angular/core';
import { ToastService } from './toast.service';

@Injectable({
  providedIn: 'root'
})
export class PodcastService {

  constructor(private toast: ToastService) { }

  search(){
    this.toast.info("SEARCH");
  }

  s2(){
    this.toast.error();
  }
}
