/// <reference lib="webworker" />

import * as log from 'electron-log';
import * as parsePodcast from 'node-podcast-parser';

addEventListener('message', ({ data }) => {
	let updatedValue = [];
	const promises = [];
	data.forEach((fav: any) => {
		const promise = fetch(fav.rss)
			.then((response) => {
				return response.text();
			}).then((data) => {
				const currentPodcastEpisodes = [];
				parsePodcast(data, (error, data) => {
					if (error) {
						log.error("Latest episode worker :: " + error);
					} else {
						data.episodes.forEach(y => {
							const episode = {
								title: y.title || 'Podcast',
								podcast: data.title || 'Podcast Title',
								src: y.enclosure ? y.enclosure.url || '' : '',
								cover: y.image || data.image,
								guid: y.guid || '',
								rss: fav.rss || '',
								date: y.published || ''
							}
							currentPodcastEpisodes.push(episode);
						})
					}
				})
				updatedValue = [...updatedValue, ...currentPodcastEpisodes];
			}).catch((error) => {
				log.error("Latest episode worker ::" + error);
			});
		promises.push(promise);
	});
	Promise.all(promises).then(() => {
		postMessage(updatedValue);
	}).catch((error) => {
		log.error("Latest episode worker :: " + error);
	});
});
