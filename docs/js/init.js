(function ($) {
  $(function () {

    $('.sidenav').sidenav();
    $('.collapsible').collapsible();
    $('.parallax').parallax();
    $('.carousel.carousel-slider').carousel({
      indicators: true,
      duration: 500
    });
    setTimeout(autoplay, 10000);
    function autoplay() {
      $('.carousel').carousel('next');
      setTimeout(autoplay, 10000);
    }

  }); // end of document ready
})(jQuery); // end of jQuery name space
