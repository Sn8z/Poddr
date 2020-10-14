const getGitHubStats = () => {
	fetch('https://api.github.com/repos/sn8z/poddr/releases')
		.then((response) => response.json())
		.then((data) => {
			const assets = data[0].assets;
			assets.forEach((asset) => {
				switch (true) {
					case asset.content_type === 'application/x-ms-dos-executable':
						document.querySelector('#exe-download').href = asset.browser_download_url;
						break;
					case asset.content_type === 'application/x-iso9660-appimage':
						document.querySelector('#appimage-download').href = asset.browser_download_url;
						break;
					case asset.content_type === 'application/vnd.debian.binary-package':
						document.querySelector('#deb-download').href = asset.browser_download_url;
						break;
					case asset.content_type === 'application/x-apple-diskimage':
						document.querySelector('#dmg-download').href = asset.browser_download_url;
						break;
					default:
						console.log(asset.content_type + ' did not match any case.');
				}
			});
		})
		.catch((error) => {
			console.error('Error => ', error);
		});
};

const initAnalytics = function () {
	window.dataLayer = window.dataLayer || [];
	const gtag = () => {
		dataLayer.push(arguments);
	};
	gtag('js', new Date());
	gtag('config', 'UA-83028441-2');
};

document.addEventListener("DOMContentLoaded", () => {
	getGitHubStats();
	initAnalytics();
});