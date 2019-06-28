import { Injectable } from '@angular/core';
import * as log from 'electron-log';
import { AudioService } from './audio.service';
import * as Mousetrap from 'mousetrap';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class HotkeysService {

  constructor(private audio: AudioService, private router: Router) {
    log.info("Loading hotkeys");
    this.addGlobalBind();
    this.loadBinds();
  }

  private addGlobalBind(): void {
    let _globalCallbacks = {};
    let _originalStopCallback = Mousetrap.prototype.stopCallback;

    Mousetrap.prototype.stopCallback = function (e, element, combo, sequence) {
      var self = this;
      if (self.paused) { return true; }
      if (_globalCallbacks[combo] || _globalCallbacks[sequence]) {
        return false;
      }
      return _originalStopCallback.call(self, e, element, combo);
    };

    Mousetrap.prototype.bindGlobal = function (keys, callback, action) {
      var self = this;
      self.bind(keys, callback, action);
      if (keys instanceof Array) {
        for (var i = 0; i < keys.length; i++) {
          _globalCallbacks[keys[i]] = true;
        }
        return;
      }
      _globalCallbacks[keys] = true;
    };
    Mousetrap.init();
  }

  private loadBinds(): void {
    Mousetrap.bind("space", (e) => {
      e.preventDefault();
      this.audio.togglePlay();
    });

    Mousetrap.bindGlobal("mod+up", (e) => {
      e.preventDefault();
      this.audio.changeVolume(0.005);
    });

    Mousetrap.bindGlobal("mod+down", (e) => {
      e.preventDefault();
      this.audio.changeVolume(-0.005);
    });

    Mousetrap.bindGlobal("mod+left", (e) => {
      e.preventDefault();
      this.audio.changeTime(-1);
    });

    Mousetrap.bindGlobal("mod+right", (e) => {
      e.preventDefault();
      this.audio.changeTime(1);
    });

    Mousetrap.bindGlobal("mod+1", (e) => {
      e.preventDefault();
      this.router.navigateByUrl("/toplists");
    });

    Mousetrap.bindGlobal(["mod+2", "mod+f", "mod+l"], (e) => {
      e.preventDefault();
      this.router.navigateByUrl("/search");
    });

    Mousetrap.bindGlobal("mod+3", (e) => {
      e.preventDefault();
      this.router.navigateByUrl("/favourites");
    });

    Mousetrap.bindGlobal("mod+4", (e) => {
      e.preventDefault();
      this.router.navigateByUrl("/discover");
    });

    Mousetrap.bindGlobal("mod+5", (e) => {
      e.preventDefault();
      this.router.navigateByUrl("/settings");
    });

  }
}
