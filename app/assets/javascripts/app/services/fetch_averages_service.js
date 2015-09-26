var changeHourOnDate = function(date, hour) {
  var newDate = new Date(date);
  newDate.setHours(hour);
  return newDate;
};

var buildMissingDatesInDay = function(arr) {
  var date = arr[0].averageDate;
  var firstHour = date.getHours();
  var lastHour = arr[arr.length - 1].averageDate.getHours();

  for(var i = firstHour - 1; i >= 0; i--) {
    arr.unshift({
      averageDate: changeHourOnDate(date, i),
      averageValue: 0
    });
  }

  for(var j = lastHour + 1; j < 24; j++) {
    arr.push({
      averageDate: changeHourOnDate(date, j),
      averageValue: 0
    });
  }
};

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
            averageDate: new Date(dataPoint.averageDate),
            averageValue: dataPoint.averageValue
          };
        }), 'averageDate');


        // Adds missing hours if date was specified
        if(output.length && output.length < 24) {
          if(params.before) {
            buildMissingDatesInDay(output);
          }
        }

        output.meta = data.meta;

        return output;
      });
    };
  }
]);