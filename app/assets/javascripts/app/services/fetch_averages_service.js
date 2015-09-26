angular.module('app').factory('fetchAverages', [
  'Restangular', 
  function(Restangular) {
    return function(origin, params) {
      if(_.isUndefined(params)) {
        params = {};
      }

      var path = 'pings/' + origin + '/hours';

      return Restangular.all(path).getList(params).then(function(data) {
        var output = _.sortByOrder(data.map(function(dataPoint) {
          return {
            pingHourCreatedAt: new Date(dataPoint.pingHourCreatedAt),
            averageTransferTimeMs: dataPoint.averageTransferTimeMs
          };
        }), 'pingHourCreatedAt');


        // Adds data points to the front of the array if less than 24 are returned
        if(output.length < 24) {
          var firstDate = output[0].pingHourCreatedAt;
          for(var i = 1; i <= 24 - output.length; i++) {
            output.unshift({
              pingHourCreatedAt: new Date(+firstDate - i * 3600 * 1000),
              averageTransferTimeMs: 0
            });
          }
        }

        output.meta = data.meta;

        return output;
      });
    };
  }
]);