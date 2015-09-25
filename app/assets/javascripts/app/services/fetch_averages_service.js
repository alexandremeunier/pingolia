angular.module('app').factory('fetchAverages', [
  'Restangular', 
  function(Restangular) {
    return function(origin, params) {
      if(_.isUndefined(params)) {
        params = {};
      }

      var path = 'pings/' + origin + '/hours';

      return Restangular.all(path, params).getList().then(function(data) {
        return _.sortByOrder(data.map(function(dataPoint) {
          return {
            pingHourCreatedAt: new Date(dataPoint.ping_hour_created_at),
            averageTransferTimeMs: dataPoint.average_transfer_time_ms
          };
        }), 'pingHourCreatedAt');
      });
    };
  }
]);