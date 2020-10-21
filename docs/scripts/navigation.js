const toggleNav = () => {
	document.querySelector('nav').classList.toggle('active');
	document.querySelector('#hamburger').classList.toggle('active');
};

const navigateTo = (anchor) => {
		location.hash = anchor;
		document.querySelector('nav').classList.remove('active');
		document.querySelector('#hamburger').classList.remove('active');
};
