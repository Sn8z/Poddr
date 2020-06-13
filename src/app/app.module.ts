// Angular modules
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { NgSelectModule } from '@ng-select/ng-select';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';

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
import { LatestComponent } from './latest/latest.component';
import { FavouritesComponent } from './favourites/favourites.component';
import { SearchComponent } from './search/search.component';
import { SettingsComponent } from './settings/settings.component';
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
    LatestComponent,
    FavouritesComponent,
    SearchComponent,
    SettingsComponent,
    PodcastComponent
  ],
  imports: [
		BrowserModule,
		FormsModule,
		NgSelectModule,
		HttpClientModule,
		AppRoutingModule,
		FontAwesomeModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
