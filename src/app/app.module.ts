import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { TitlebarComponent } from './titlebar/titlebar.component';
import { SidenavComponent } from './sidenav/sidenav.component';
import { PlayerComponent } from './player/player.component';
import { ToplistsComponent } from './toplists/toplists.component';
import { FavouritesComponent } from './favourites/favourites.component';
import { SearchComponent } from './search/search.component';
import { DiscoverComponent } from './discover/discover.component';
import { SettingsComponent } from './settings/settings.component';
import { AppearanceComponent } from './appearance/appearance.component';

@NgModule({
  declarations: [
    AppComponent,
    TitlebarComponent,
    SidenavComponent,
    PlayerComponent,
    ToplistsComponent,
    FavouritesComponent,
    SearchComponent,
    DiscoverComponent,
    SettingsComponent,
    AppearanceComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
