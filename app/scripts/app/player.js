angular.module('poddr').controller(
  "PlayerController", function($scope, $rootScope, PlayerService){
    player = new Audio();

    player.volume = 0.5;
    $scope.barWidth = "0%";
    $scope.volume = player.volume;

    $scope.setVolume = function() {
      player.volume = $scope.volume;
    };

    player.addEventListener('timeupdate',function (){
      PlayerService.atTime = player.currentTime;
      $scope.barWidth = getBarWidth();
      $scope.$apply();
    });

    var progress = document.getElementById('progress');
    progress.addEventListener('click', function(e) {
      var $this = $(this);

      var widthclicked = e.pageX - $this.offset().left;
      var totalWidth = $this.width();

      var calc = (widthclicked / totalWidth) * player.duration; // get the percent of bar clicked and multiply in by the duration
      player.currentTime = calc.toFixed(0);
    });

    $scope.checkPlayBtn = function(){
      if(player.paused){
        return "play_arrow";
      } else {
        return "pause";
      }
    }

    $scope.currentlyPlaying = function(){
      return PlayerService.currentlyPlaying;
    }

    $scope.currentTime = function(){
      return PlayerService.atTime;
    }

    $scope.podcastDuration = function(){
      return PlayerService.podcastDuration;
    }

    function getBarWidth(){
      return ((player.currentTime/player.duration) * 100) + "%";
    }

    $scope.getAlbumCover = function(){
      return PlayerService.albumCover;
    }

    player.addEventListener("canplaythrough", function(e) {
      PlayerService.podcastDuration = player.duration;
    })

    function playPodcast(episode, album_cover){
      url = episode.files[0].urls[0];
      player.src = url;
      player.play();
      PlayerService.currentlyPlaying = episode.title;
      PlayerService.podcastDuration = 0;
      PlayerService.albumCover = album_cover;
    }
    $rootScope.playPodcast = playPodcast;

    function togglePlay() {
      if (player.paused) {
        player.play();
      } else {
        player.pause();
      }
    }
    $rootScope.togglePlay = togglePlay;

  });
