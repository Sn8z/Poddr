angular
  .module("poddr")
  .controller("FavouritesController", function (
    $scope,
    $rootScope,
    FavouriteService,
    FavouriteFactory
  ) {
    $scope.favourites = FavouriteFactory.getList();
    $scope.showEpisodes = $rootScope.fetchEpisodes;
    $scope.removeFavourite = function (id) {
      FavouriteService.removeFavourite(id).then(function (response) {
        if (response) {
          delete $scope.favourites[id];
        }
      });
    }
  });
