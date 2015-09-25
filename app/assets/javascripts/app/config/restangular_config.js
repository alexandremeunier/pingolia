angular.module('app').config([
  'RestangularProvider',
  function(RestangularProvider) {
    RestangularProvider.setBaseUrl('/api/1/');
    RestangularProvider.setRequestSuffix('.json');
  }
]);