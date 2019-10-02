import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import * as Store from 'electron-store';
import * as log from 'electron-log';

@Injectable({
  providedIn: 'root'
})
export class PlayedService {
  private store: Store<any> = new Store({ name: "previouslyPlayed" });

  playedEpisodes: BehaviorSubject<string[]> = new BehaviorSubject<string[]>([]);

  constructor() {
    this.updatePlayedEpisodes();
  }

  private updatePlayedEpisodes = () => {
    this.playedEpisodes.next(Object.keys(this.store.store as string[]));
  }

  markAsPlayed = (guid: string) => {
    this.store.set(guid.replace(/\./g, '\\.'), Date.now());
    this.updatePlayedEpisodes();
    log.info("PrevPlayed service :: Added " + guid + " to previously played episodes.");
  }

  unmarkAsPlayed = (guid: string) => {
    this.store.delete(guid);
    this.updatePlayedEpisodes();
    log.info("PrevPlayed service :: Removed " + guid + " from previously played episodes.");
  }

}
