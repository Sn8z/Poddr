angular
  .module("poddr")
  .controller("PlayerController", function(
    $scope,
    $rootScope,
    PlayerService,
    $mdToast,
    $window
  ) {
    var storage = require("electron-json-storage");
    var ipc = require("electron").ipcRenderer;

    //create the audio element
    var player = document.createElement("audio");

    player.volume = 0.5;
    $scope.barWidth = "0%";
    $scope.volume = player.volume;
    $scope.isLoading = false;

    //listen for messages from main process
    ipc.on("toggle-play", function(event, message) {
      togglePlay();
    });

    //set initial volume based on previous session if available
    storage.get("volume", function(error, data) {
      if (error) throw error;
      player.volume = data.value;
      $scope.volume = data.value;
      $scope.$apply();
    });

    $scope.setVolume = function() {
      player.volume = $scope.volume;
      storage.set("volume", { value: player.volume }, function(err) {
        if (err) throw err;
      });
    };

    player.addEventListener("loadstart", function() {
      $scope.isLoading = true;
      $scope.$apply();
    });

    player.addEventListener("timeupdate", function() {
      PlayerService.atTime = player.currentTime;
      $scope.barWidth = getBarWidth();
      $scope.$apply();
    });

    player.addEventListener("seeking", function() {
      $scope.isLoading = true;
      $scope.$apply();
    });

    player.addEventListener("canplaythrough", function(e) {
      PlayerService.podcastDuration = player.duration;
      $scope.isLoading = false;
    });

    player.addEventListener("ended", function() {
      $mdToast.show(
        $mdToast
          .simple()
          .textContent("Podcast ended.")
          .position("top right")
          .hideDelay(3000)
          .toastClass("md-toast-success")
      );
    });

    player.addEventListener("error", function failed(e) {
      console.log("Player src error: " + e.target.error.code);
      $mdToast.show(
        $mdToast
          .simple()
          .textContent("Source error.")
          .position("top right")
          .hideDelay(3000)
          .toastClass("md-toast-error")
      );
    });

    function playPodcast(episode, podcastCover) {
      url = episode.enclosure.url;
      player.src = url;
      player.play();
      PlayerService.currentlyPlaying = episode.title;
      PlayerService.podcastDuration = 0;
      if (episode.image == null) {
        PlayerService.albumCover = podcastCover;
      } else {
        PlayerService.albumCover = episode.image;
      }
      $rootScope.toggleSidebar();
    }
    $rootScope.playPodcast = playPodcast;

    var progress = document.getElementById("progress");
    progress.addEventListener(
      "click",
      function(event) {
        var width = event.clientX - progress.getBoundingClientRect().left;
        var calc = width / progress.offsetWidth * player.duration;
        player.currentTime = parseFloat(calc);
      },
      true
    );

    $scope.checkPlayBtn = function() {
      if (player.paused) {
        return "play_circle_outline";
      } else {
        return "pause_circle_outline";
      }
    };

    $scope.checkVolume = function() {
      if (player.volume == 0 || player.muted) {
        return "volume_off";
      } else {
        return "volume_up";
      }
    };

    $scope.currentlyPlaying = function() {
      return PlayerService.currentlyPlaying;
    };

    $scope.currentTime = function() {
      return PlayerService.atTime;
    };

    $scope.podcastDuration = function() {
      return PlayerService.podcastDuration;
    };

    function getBarWidth() {
      return player.currentTime / player.duration * 100 + "%";
    }

    $scope.getAlbumCover = function() {
      return PlayerService.albumCover;
    };

    function togglePlay() {
      $window.document.getElementById("play-btn").blur();
      if (player.src) {
        if (player.paused) {
          player.play();
        } else {
          player.pause();
        }
      }
    }
    $rootScope.togglePlay = togglePlay;

    function toggleMute() {
      console.log("mute");
      if (player.muted) {
        player.muted = false;
      } else {
        player.muted = true;
      }
    }
    $rootScope.toggleMute = toggleMute;

    function volumeUp() {
      if (player.volume + 0.005 > 1) {
        player.volume = 1;
        $scope.volume = player.volume;
      } else {
        player.volume = player.volume + 0.005;
        $scope.volume = player.volume;
      }
      storage.set("volume", { value: player.volume }, function(err) {
        if (err) throw err;
      });
      $scope.$apply();
    }
    $rootScope.volumeUp = volumeUp;

    function volumeDown() {
      if (player.volume - 0.005 < 0) {
        player.volume = 0;
        $scope.volume = player.volume;
      } else {
        player.volume = player.volume - 0.005;
        $scope.volume = player.volume;
      }
      storage.set("volume", { value: player.volume }, function(err) {
        if (err) throw err;
      });
      $scope.$apply();
    }
    $rootScope.volumeDown = volumeDown;
  });
