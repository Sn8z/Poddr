// Angular modules
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';

// Pipes
import { ItunesImage } from './pipes/itunes-image.pipe';
import { Description } from './pipes/description.pipe';
import { SecondsToHhMmSs } from './pipes/secondsToHhMmSs.pipe';

// Routing & Components
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
import { PodcastComponent } from './podcast/podcast.component';

@NgModule({
  declarations: [
		AppComponent,
    ItunesImage,
    Description,
    SecondsToHhMmSs,
    TitlebarComponent,
    SidenavComponent,
    PlayerComponent,
    ToplistsComponent,
    FavouritesComponent,
    SearchComponent,
    DiscoverComponent,
    SettingsComponent,
    AppearanceComponent,
    PodcastComponent
  ],
  imports: [
		BrowserModule,
		FormsModule,
		HttpClientModule,
    AppRoutingModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
