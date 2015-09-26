angular.module('app').directive('chartLoadingOverlay', function() {
  return {
    restrict: 'EA',
    scope: true,
    replace: true,
    templateUrl: 'chart_loading_overlay.html'
  };
});