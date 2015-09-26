angular.module('app').factory('fetchAverages', [
  'Restangular', 
  function(Restangular) {
    return function(origin, params) {
      if(_.isUndefined(params)) {
        params = {};
      }

      console.log('lapin', params)

      var path = 'pings/' + origin + '/hours';

      return Restangular.all(path).getList(params).then(function(data) {
        var output = _.sortByOrder(data.map(function(dataPoint) {
          return {
            pingHourCreatedAt: new Date(dataPoint.pingHourCreatedAt),
            averageTransferTimeMs: dataPoint.averageTransferTimeMs
          };
        }), 'pingHourCreatedAt');

        output.meta = data.meta;

        return output;
      });
    };
  }
]);