angular.module('app').config([
  'RestangularProvider',
  function(RestangularProvider) {
    RestangularProvider.setBaseUrl('/api/1/');
    RestangularProvider.setRequestSuffix('.json');

    RestangularProvider.addResponseInterceptor(function(data, operation, what, url, response, deferred) {
      var extractedData;
      if(operation === 'getList' && _.isObject(data) && data.data) {
        extractedData = data.data;
        extractedData.meta = data.meta;
      } else {
        extractedData = data;
      }

      return extractedData;
    });
  }
]);