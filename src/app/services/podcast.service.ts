import { Injectable } from '@angular/core';
import { ToastService } from './toast.service';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import * as log from 'electron-log';

@Injectable({
	providedIn: 'root'
})
export class PodcastService {

	constructor(private toast: ToastService, private http: HttpClient) { }

	getToplist(region: String, category: String, amount: Number): Observable<any> {
		log.info("Podcast service :: Fetching top " + amount + " podcasts in " + region + " (" + category + ")");
		return this.http.get("https://itunes.apple.com/" + region + "/rss/topaudiopodcasts/limit=" + amount + "/genre=" + category + "/json");
	}

	search(query: String = ""): Observable<any> {
		//replace åäö
		let sQuery = query.replace(/[\u00e4\u00c4\u00c5\u00e5]/g, "a");
		sQuery = sQuery.replace(/[\u00d6\u00f6]/g, "o");
		log.info("Podcast service :: Searching using query => " + sQuery);
		return this.http.get("https://itunes.apple.com/search?term=" + sQuery + "&entity=podcast&attributes=titleTerm,artistTerm&limit=200");
	}

	getRssFeed(id: String): Observable<any> {
		log.info("Podcast service :: Getting RSS feed using ID => " + id);
		return this.http.get("https://itunes.apple.com/lookup?id=" + id);
	}

	getPodcastFeed(rss: String): Observable<any> {
		log.info("Podcast service :: Getting Podcastfeed using RSS => " + rss);
		return this.http.get("" + rss, { responseType: 'text' });
	}

	getEpisodeBlob(url: String): Observable<Blob> {
		log.info("Podcast Service :: Getting podcast at: " + url);
		return this.http.get("" + url, { responseType: 'blob' });
	}

	getRegions(): Array<any> {
		return [
			{
				"id": "ai",
				"type": "storefronts",
				"href": "/v1/storefronts/ai",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Anguilla",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ag",
				"type": "storefronts",
				"href": "/v1/storefronts/ag",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Antigua and Barbuda",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ar",
				"type": "storefronts",
				"href": "/v1/storefronts/ar",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Argentina",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "am",
				"type": "storefronts",
				"href": "/v1/storefronts/am",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Armenia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "au",
				"type": "storefronts",
				"href": "/v1/storefronts/au",
				"attributes": {
					"defaultLanguageTag": "en-au",
					"name": "Australia",
					"supportedLanguageTags": [
						"en-au"
					]
				}
			},
			{
				"id": "at",
				"type": "storefronts",
				"href": "/v1/storefronts/at",
				"attributes": {
					"defaultLanguageTag": "de-de",
					"name": "Austria",
					"supportedLanguageTags": [
						"de-de",
						"en-gb"
					]
				}
			},
			{
				"id": "az",
				"type": "storefronts",
				"href": "/v1/storefronts/az",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Azerbaijan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "bh",
				"type": "storefronts",
				"href": "/v1/storefronts/bh",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Bahrain",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "bb",
				"type": "storefronts",
				"href": "/v1/storefronts/bb",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Barbados",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "by",
				"type": "storefronts",
				"href": "/v1/storefronts/by",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Belarus",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "be",
				"type": "storefronts",
				"href": "/v1/storefronts/be",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Belgium",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr",
						"nl-nl"
					]
				}
			},
			{
				"id": "bz",
				"type": "storefronts",
				"href": "/v1/storefronts/bz",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Belize",
					"supportedLanguageTags": [
						"en-gb",
						"es-mx"
					]
				}
			},
			{
				"id": "bm",
				"type": "storefronts",
				"href": "/v1/storefronts/bm",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Bermuda",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "bo",
				"type": "storefronts",
				"href": "/v1/storefronts/bo",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Bolivia",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "bw",
				"type": "storefronts",
				"href": "/v1/storefronts/bw",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Botswana",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "br",
				"type": "storefronts",
				"href": "/v1/storefronts/br",
				"attributes": {
					"defaultLanguageTag": "pt-br",
					"name": "Brazil",
					"supportedLanguageTags": [
						"pt-br",
						"en-gb"
					]
				}
			},
			{
				"id": "vg",
				"type": "storefronts",
				"href": "/v1/storefronts/vg",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "British Virgin Islands",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "bg",
				"type": "storefronts",
				"href": "/v1/storefronts/bg",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Bulgaria",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "kh",
				"type": "storefronts",
				"href": "/v1/storefronts/kh",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Cambodia",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "ca",
				"type": "storefronts",
				"href": "/v1/storefronts/ca",
				"attributes": {
					"defaultLanguageTag": "en-ca",
					"name": "Canada",
					"supportedLanguageTags": [
						"en-ca",
						"fr-ca"
					]
				}
			},
			{
				"id": "cv",
				"type": "storefronts",
				"href": "/v1/storefronts/cv",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Cape Verde",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ky",
				"type": "storefronts",
				"href": "/v1/storefronts/ky",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Cayman Islands",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "cl",
				"type": "storefronts",
				"href": "/v1/storefronts/cl",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Chile",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "cn",
				"type": "storefronts",
				"href": "/v1/storefronts/cn",
				"attributes": {
					"defaultLanguageTag": "zh-cn",
					"name": "China",
					"supportedLanguageTags": [
						"zh-cn",
						"en-gb"
					]
				}
			},
			{
				"id": "co",
				"type": "storefronts",
				"href": "/v1/storefronts/co",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Colombia",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "cr",
				"type": "storefronts",
				"href": "/v1/storefronts/cr",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Costa Rica",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "cy",
				"type": "storefronts",
				"href": "/v1/storefronts/cy",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Cyprus",
					"supportedLanguageTags": [
						"en-gb",
						"el-gr",
						"tr-tr"
					]
				}
			},
			{
				"id": "cz",
				"type": "storefronts",
				"href": "/v1/storefronts/cz",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Czech Republic",
					"supportedLanguageTags": [
						"en-gb",
						"cs-cz"
					]
				}
			},
			{
				"id": "dk",
				"type": "storefronts",
				"href": "/v1/storefronts/dk",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Denmark",
					"supportedLanguageTags": [
						"en-gb",
						"da-dk"
					]
				}
			},
			{
				"id": "dm",
				"type": "storefronts",
				"href": "/v1/storefronts/dm",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Dominica",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "do",
				"type": "storefronts",
				"href": "/v1/storefronts/do",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Dominican Republic",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "ec",
				"type": "storefronts",
				"href": "/v1/storefronts/ec",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Ecuador",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "eg",
				"type": "storefronts",
				"href": "/v1/storefronts/eg",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Egypt",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "sv",
				"type": "storefronts",
				"href": "/v1/storefronts/sv",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "El Salvador",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "ee",
				"type": "storefronts",
				"href": "/v1/storefronts/ee",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Estonia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "fj",
				"type": "storefronts",
				"href": "/v1/storefronts/fj",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Fiji",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "fi",
				"type": "storefronts",
				"href": "/v1/storefronts/fi",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Finland",
					"supportedLanguageTags": [
						"en-gb",
						"fi-fi"
					]
				}
			},
			{
				"id": "fr",
				"type": "storefronts",
				"href": "/v1/storefronts/fr",
				"attributes": {
					"defaultLanguageTag": "fr-fr",
					"name": "France",
					"supportedLanguageTags": [
						"fr-fr",
						"en-gb"
					]
				}
			},
			{
				"id": "gm",
				"type": "storefronts",
				"href": "/v1/storefronts/gm",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Gambia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "de",
				"type": "storefronts",
				"href": "/v1/storefronts/de",
				"attributes": {
					"defaultLanguageTag": "de-de",
					"name": "Germany",
					"supportedLanguageTags": [
						"de-de",
						"en-gb"
					]
				}
			},
			{
				"id": "gh",
				"type": "storefronts",
				"href": "/v1/storefronts/gh",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Ghana",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "gr",
				"type": "storefronts",
				"href": "/v1/storefronts/gr",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Greece",
					"supportedLanguageTags": [
						"en-gb",
						"el-gr"
					]
				}
			},
			{
				"id": "gd",
				"type": "storefronts",
				"href": "/v1/storefronts/gd",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Grenada",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "gt",
				"type": "storefronts",
				"href": "/v1/storefronts/gt",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Guatemala",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "gw",
				"type": "storefronts",
				"href": "/v1/storefronts/gw",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Guinea-Bissau",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "hn",
				"type": "storefronts",
				"href": "/v1/storefronts/hn",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Honduras",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "hk",
				"type": "storefronts",
				"href": "/v1/storefronts/hk",
				"attributes": {
					"defaultLanguageTag": "zh-hk",
					"name": "Hong Kong",
					"supportedLanguageTags": [
						"zh-hk",
						"zh-tw",
						"en-gb"
					]
				}
			},
			{
				"id": "hu",
				"type": "storefronts",
				"href": "/v1/storefronts/hu",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Hungary",
					"supportedLanguageTags": [
						"en-gb",
						"hu-hu"
					]
				}
			},
			{
				"id": "in",
				"type": "storefronts",
				"href": "/v1/storefronts/in",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "India",
					"supportedLanguageTags": [
						"en-gb",
						"hi-in"
					]
				}
			},
			{
				"id": "id",
				"type": "storefronts",
				"href": "/v1/storefronts/id",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Indonesia",
					"supportedLanguageTags": [
						"en-gb",
						"id-id"
					]
				}
			},
			{
				"id": "ie",
				"type": "storefronts",
				"href": "/v1/storefronts/ie",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Ireland",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "il",
				"type": "storefronts",
				"href": "/v1/storefronts/il",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Israel",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "it",
				"type": "storefronts",
				"href": "/v1/storefronts/it",
				"attributes": {
					"defaultLanguageTag": "it-it",
					"name": "Italy",
					"supportedLanguageTags": [
						"it-it",
						"en-gb"
					]
				}
			},
			{
				"id": "jp",
				"type": "storefronts",
				"href": "/v1/storefronts/jp",
				"attributes": {
					"defaultLanguageTag": "ja-jp",
					"name": "Japan",
					"supportedLanguageTags": [
						"ja-jp",
						"en-us"
					]
				}
			},
			{
				"id": "jo",
				"type": "storefronts",
				"href": "/v1/storefronts/jo",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Jordan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "kz",
				"type": "storefronts",
				"href": "/v1/storefronts/kz",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Kazakhstan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ke",
				"type": "storefronts",
				"href": "/v1/storefronts/ke",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Kenya",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "kr",
				"type": "storefronts",
				"href": "/v1/storefronts/kr",
				"attributes": {
					"defaultLanguageTag": "ko-kr",
					"name": "Korea, Republic of",
					"supportedLanguageTags": [
						"ko-kr",
						"en-gb"
					]
				}
			},
			{
				"id": "kg",
				"type": "storefronts",
				"href": "/v1/storefronts/kg",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Kyrgyzstan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "la",
				"type": "storefronts",
				"href": "/v1/storefronts/la",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Lao People's Democratic Republic",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "lv",
				"type": "storefronts",
				"href": "/v1/storefronts/lv",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Latvia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "lb",
				"type": "storefronts",
				"href": "/v1/storefronts/lb",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Lebanon",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "lt",
				"type": "storefronts",
				"href": "/v1/storefronts/lt",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Lithuania",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "lu",
				"type": "storefronts",
				"href": "/v1/storefronts/lu",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Luxembourg",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr",
						"de-de"
					]
				}
			},
			{
				"id": "mo",
				"type": "storefronts",
				"href": "/v1/storefronts/mo",
				"attributes": {
					"defaultLanguageTag": "zh-hk",
					"name": "Macau",
					"supportedLanguageTags": [
						"zh-hk",
						"zh-tw",
						"en-gb"
					]
				}
			},
			{
				"id": "my",
				"type": "storefronts",
				"href": "/v1/storefronts/my",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Malaysia",
					"supportedLanguageTags": [
						"en-gb",
						"ms-my"
					]
				}
			},
			{
				"id": "mt",
				"type": "storefronts",
				"href": "/v1/storefronts/mt",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Malta",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "mu",
				"type": "storefronts",
				"href": "/v1/storefronts/mu",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Mauritius",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "mx",
				"type": "storefronts",
				"href": "/v1/storefronts/mx",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Mexico",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "fm",
				"type": "storefronts",
				"href": "/v1/storefronts/fm",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Micronesia, Federated States of",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "md",
				"type": "storefronts",
				"href": "/v1/storefronts/md",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Moldova",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "mn",
				"type": "storefronts",
				"href": "/v1/storefronts/mn",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Mongolia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "np",
				"type": "storefronts",
				"href": "/v1/storefronts/np",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Nepal",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "nl",
				"type": "storefronts",
				"href": "/v1/storefronts/nl",
				"attributes": {
					"defaultLanguageTag": "nl-nl",
					"name": "Netherlands",
					"supportedLanguageTags": [
						"nl-nl",
						"en-gb"
					]
				}
			},
			{
				"id": "nz",
				"type": "storefronts",
				"href": "/v1/storefronts/nz",
				"attributes": {
					"defaultLanguageTag": "en-au",
					"name": "New Zealand",
					"supportedLanguageTags": [
						"en-au"
					]
				}
			},
			{
				"id": "ni",
				"type": "storefronts",
				"href": "/v1/storefronts/ni",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Nicaragua",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "ne",
				"type": "storefronts",
				"href": "/v1/storefronts/ne",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Niger",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "ng",
				"type": "storefronts",
				"href": "/v1/storefronts/ng",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Nigeria",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "no",
				"type": "storefronts",
				"href": "/v1/storefronts/no",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Norway",
					"supportedLanguageTags": [
						"en-gb",
						"no-no"
					]
				}
			},
			{
				"id": "om",
				"type": "storefronts",
				"href": "/v1/storefronts/om",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Oman",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "pa",
				"type": "storefronts",
				"href": "/v1/storefronts/pa",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Panama",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "pg",
				"type": "storefronts",
				"href": "/v1/storefronts/pg",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Papua New Guinea",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "py",
				"type": "storefronts",
				"href": "/v1/storefronts/py",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Paraguay",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "pe",
				"type": "storefronts",
				"href": "/v1/storefronts/pe",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Peru",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "ph",
				"type": "storefronts",
				"href": "/v1/storefronts/ph",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Philippines",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "pl",
				"type": "storefronts",
				"href": "/v1/storefronts/pl",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Poland",
					"supportedLanguageTags": [
						"en-gb",
						"pl-pl"
					]
				}
			},
			{
				"id": "pt",
				"type": "storefronts",
				"href": "/v1/storefronts/pt",
				"attributes": {
					"defaultLanguageTag": "pt-pt",
					"name": "Portugal",
					"supportedLanguageTags": [
						"pt-pt",
						"en-gb"
					]
				}
			},
			{
				"id": "ro",
				"type": "storefronts",
				"href": "/v1/storefronts/ro",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Romania",
					"supportedLanguageTags": [
						"en-gb",
						"ro-ro"
					]
				}
			},
			{
				"id": "ru",
				"type": "storefronts",
				"href": "/v1/storefronts/ru",
				"attributes": {
					"defaultLanguageTag": "ru-ru",
					"name": "Russia",
					"supportedLanguageTags": [
						"ru-ru",
						"en-gb",
						"uk-ua"
					]
				}
			},
			{
				"id": "sa",
				"type": "storefronts",
				"href": "/v1/storefronts/sa",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Saudi Arabia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "sg",
				"type": "storefronts",
				"href": "/v1/storefronts/sg",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Singapore",
					"supportedLanguageTags": [
						"en-gb",
						"zh-cn"
					]
				}
			},
			{
				"id": "sk",
				"type": "storefronts",
				"href": "/v1/storefronts/sk",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Slovakia",
					"supportedLanguageTags": [
						"en-gb",
						"sk-sk"
					]
				}
			},
			{
				"id": "si",
				"type": "storefronts",
				"href": "/v1/storefronts/si",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Slovenia",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "za",
				"type": "storefronts",
				"href": "/v1/storefronts/za",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "South Africa",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "es",
				"type": "storefronts",
				"href": "/v1/storefronts/es",
				"attributes": {
					"defaultLanguageTag": "es-es",
					"name": "Spain",
					"supportedLanguageTags": [
						"es-es",
						"ca-es",
						"en-gb"
					]
				}
			},
			{
				"id": "lk",
				"type": "storefronts",
				"href": "/v1/storefronts/lk",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Sri Lanka",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "kn",
				"type": "storefronts",
				"href": "/v1/storefronts/kn",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "St. Kitts and Nevis",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "sz",
				"type": "storefronts",
				"href": "/v1/storefronts/sz",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Swaziland",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "se",
				"type": "storefronts",
				"href": "/v1/storefronts/se",
				"attributes": {
					"defaultLanguageTag": "sv-se",
					"name": "Sweden",
					"supportedLanguageTags": [
						"sv-se",
						"en-gb"
					]
				}
			},
			{
				"id": "ch",
				"type": "storefronts",
				"href": "/v1/storefronts/ch",
				"attributes": {
					"defaultLanguageTag": "de-ch",
					"name": "Switzerland",
					"supportedLanguageTags": [
						"de-ch",
						"de-de",
						"en-gb",
						"fr-fr",
						"it-it"
					]
				}
			},
			{
				"id": "tw",
				"type": "storefronts",
				"href": "/v1/storefronts/tw",
				"attributes": {
					"defaultLanguageTag": "zh-tw",
					"name": "Taiwan",
					"supportedLanguageTags": [
						"zh-tw",
						"en-gb"
					]
				}
			},
			{
				"id": "tj",
				"type": "storefronts",
				"href": "/v1/storefronts/tj",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Tajikistan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "th",
				"type": "storefronts",
				"href": "/v1/storefronts/th",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Thailand",
					"supportedLanguageTags": [
						"en-gb",
						"th-th"
					]
				}
			},
			{
				"id": "tt",
				"type": "storefronts",
				"href": "/v1/storefronts/tt",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Trinidad and Tobago",
					"supportedLanguageTags": [
						"en-gb",
						"fr-fr"
					]
				}
			},
			{
				"id": "tr",
				"type": "storefronts",
				"href": "/v1/storefronts/tr",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Turkey",
					"supportedLanguageTags": [
						"en-gb",
						"tr-tr"
					]
				}
			},
			{
				"id": "tm",
				"type": "storefronts",
				"href": "/v1/storefronts/tm",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Turkmenistan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ae",
				"type": "storefronts",
				"href": "/v1/storefronts/ae",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "UAE",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ug",
				"type": "storefronts",
				"href": "/v1/storefronts/ug",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Uganda",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ua",
				"type": "storefronts",
				"href": "/v1/storefronts/ua",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Ukraine",
					"supportedLanguageTags": [
						"en-gb",
						"uk-ua",
						"ru-ru"
					]
				}
			},
			{
				"id": "gb",
				"type": "storefronts",
				"href": "/v1/storefronts/gb",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "United Kingdom",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "us",
				"type": "storefronts",
				"href": "/v1/storefronts/us",
				"attributes": {
					"defaultLanguageTag": "en-us",
					"name": "United States",
					"supportedLanguageTags": [
						"en-us",
						"es-mx"
					]
				}
			},
			{
				"id": "uz",
				"type": "storefronts",
				"href": "/v1/storefronts/uz",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Uzbekistan",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			},
			{
				"id": "ve",
				"type": "storefronts",
				"href": "/v1/storefronts/ve",
				"attributes": {
					"defaultLanguageTag": "es-mx",
					"name": "Venezuela",
					"supportedLanguageTags": [
						"es-mx",
						"en-gb"
					]
				}
			},
			{
				"id": "vn",
				"type": "storefronts",
				"href": "/v1/storefronts/vn",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Vietnam",
					"supportedLanguageTags": [
						"en-gb",
						"vi-vi"
					]
				}
			},
			{
				"id": "zw",
				"type": "storefronts",
				"href": "/v1/storefronts/zw",
				"attributes": {
					"defaultLanguageTag": "en-gb",
					"name": "Zimbabwe",
					"supportedLanguageTags": [
						"en-gb"
					]
				}
			}
		];
	}

	getCategories(): Array<any> {
		return [
			{ id: 26, genre: "All" },
			{ id: 1301, genre: "Arts" },
			{ id: 1303, genre: "Comedy" },
			{ id: 1304, genre: "Education" },
			{ id: 1305, genre: "Kids & Family" },
			{ id: 1307, genre: "Health" },
			{ id: 1309, genre: "TV & Film" },
			{ id: 1310, genre: "Music" },
			{ id: 1311, genre: "News & Politics" },
			{ id: 1314, genre: "Religion & Spiritiuality" },
			{ id: 1315, genre: "Science & Medicine" },
			{ id: 1316, genre: "Sports & Recreation" },
			{ id: 1307, genre: "Health" },
			{ id: 1318, genre: "Technology" },
			{ id: 1321, genre: "Business" },
			{ id: 1323, genre: "Games & Hobbies" },
			{ id: 1324, genre: "Society & Culture" },
			{ id: 1325, genre: "Government & Organizations" }
		];
	}
}
