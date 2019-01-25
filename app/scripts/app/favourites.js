angular
  .module("poddr")
  .controller("FavouritesController", function (
    $scope,
    $rootScope,
    FavouriteService,
    FavouriteFactory
  ) {
    $scope.favourites = FavouriteFactory.getList();
    $scope.showEpisodes = $rootScope.openEpisodes;
		$scope.removeFavourite = FavouriteService.removeFavourite;
		
		$scope.isFavouritesEmpty = function(obj) {
			return angular.equals({}, obj);
		};

  });
