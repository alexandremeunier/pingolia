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

var buildMissingDatesInMonths = function(arr) {
  var date = arr[0].averageDate;

  for(var i =  1; i < 90 - arr.length; i++) {
    arr.unshift({
      averageDate: new Date(+date - i * 24 * 3600 * 1000),
      averageValue: 0
    });
  }
};

angular.module('app').factory('fetchData', [
  'Restangular', 
  function(Restangular) {
    return function(interval, origin, params) {
      if(_.isUndefined(params)) {
        params = {};
      }

      var path = 'pings/' + origin + '/' + interval;

      return Restangular.all(path).getList(params).then(function(data) {
        var output = _.sortByOrder(data.map(function(dataPoint) {
          return {
            averageDate: new Date(dataPoint.averageDate),
            averageValue: dataPoint.averageValue
          };
        }), 'averageDate');


        // Adds missing hours if date was specified
        if(interval === 'hours' && output.length && output.length < 24) {
          if(params.before) {
            buildMissingDatesInDay(output);
          }
        }


        // Add missing days if less than 3 months of data (timeline)
        if(interval === 'days' && output.length && output.length < 90) {
          if(params.before) {
            buildMissingDatesInMonths(output);
          }
        }

        output.meta = data.meta;

        return output;
      });
    };
  }
]);