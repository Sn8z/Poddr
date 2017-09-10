angular.module('poddr').controller(
  "PlayerController", function($scope, $rootScope, PlayerService, $mdToast){
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

    player.addEventListener('error', function failed(e){
      $mdToast.show(
        $mdToast.simple()
          .textContent(e.target.error.code)
          .position("top right")
          .hideDelay(3000)
          .toastClass('md-toast-error')
      );
    }, true);

    var progress = document.getElementById('progress');
    progress.addEventListener('click', function(e) {
      var $this = $(this);
      var widthclicked = e.pageX - $this.offset().left;
      var totalWidth = $this.width();
      var calc = (widthclicked / totalWidth) * player.duration;
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

    function playPodcast(episode){
      url = episode.enclosure.url
      player.src = url;
      player.play();
      PlayerService.currentlyPlaying = episode.title;
      PlayerService.podcastDuration = 0;
      PlayerService.albumCover = episode.image;
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
