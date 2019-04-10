import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { ToplistsComponent } from './toplists/toplists.component';
import { FavouritesComponent } from './favourites/favourites.component';
import { DiscoverComponent } from './discover/discover.component';
import { SearchComponent } from './search/search.component';
import { SettingsComponent } from './settings/settings.component';
import { AppearanceComponent } from './appearance/appearance.component';

const routes: Routes = [
  { path: "", redirectTo: "/toplists", pathMatch: "full" },
  { path: "toplists", component: ToplistsComponent },
  { path: "favourites", component: FavouritesComponent},
  { path: "discover", component: DiscoverComponent},
  { path: "search", component: SearchComponent},
  { path: "settings", component: SettingsComponent},
  { path: "appearance", component: AppearanceComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
