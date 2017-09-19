angular.module('poddr').controller(
  "PlayerController", function($scope, $rootScope, PlayerService, $mdToast){
    player = document.createElement('audio');

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
      console.log("Player src error: " + e.target.error.code);
      $mdToast.show(
        $mdToast.simple()
          .textContent("Source error.")
          .position("top right")
          .hideDelay(3000)
          .toastClass('md-toast-error')
      );
    }, true);

    var progress = document.getElementById('progress');
    progress.addEventListener('click', function(e) {
      var $this = $(this);
      var widthClicked = e.pageX - $this.offset().left;
      var totalWidth = $this.width();
      var calc = (widthClicked / totalWidth) * player.duration;
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

    function volumeUp(){
      if(player.volume + 0.005 > 1){
        player.volume = 1;
        $scope.volume = player.volume;
      } else {
        player.volume = player.volume + 0.005;
        $scope.volume = player.volume;
      }
      $scope.$apply();
    }
    $rootScope.volumeUp = volumeUp;

    function volumeDown(){
      if(player.volume - 0.005 < 0){
        player.volume = 0;
        $scope.volume = player.volume;
      } else {
        player.volume = player.volume - 0.005;
        $scope.volume = player.volume;
      }
      $scope.$apply();
    }
    $rootScope.volumeDown = volumeDown;

  });
