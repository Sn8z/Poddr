angular
  .module("poddr")
  .controller("FavouritesController", function (
    $scope,
    $rootScope,
    $mdDialog,
    FavouriteService,
    FavouriteFactory
  ) {
    $scope.favourites = FavouriteFactory.getList();
    $scope.showEpisodes = $rootScope.openEpisodes;
    $scope.removeFavourite = FavouriteService.removeFavourite;

    $scope.addManualFavourite = function () {
      $mdDialog.show({
        templateUrl: __dirname + "../../views/dialogs/addPodcastDialog.html",
        clickOutsideToClose: true,
        escapeToClose: true,
        controller: function ($scope, FavouriteService) {
          $scope.addPodcast = FavouriteService.addManualFavourite;
         }
      });
    };

    $scope.isFavouritesEmpty = function (obj) {
      return angular.equals({}, obj);
    };

  });
