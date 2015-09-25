var app = angular.module('app');

app.config([
  '$stateProvider',
  function($stateProvider) {
    $stateProvider.state('index', {
      url: '',
      templateUrl: 'index.html',
      controller: 'IndexController'
    });
  }
]);

app.controller('IndexController', [
  '$scope', 'fetchAverages',
  function($scope, fetchHours) {
    $scope.availableOrigins = _.map(window.AVAILABLE_ORIGINS, function(origin) {
      return {
        name: origin
      };
    });
    $scope.origin = $scope.availableOrigins[0];
    $scope.chartData = [];

    var formatHour = function(hour) {
      switch(hour) {
        case 0: return '12am';
        case 12: return '12pm';
        default: return hour >= 12 ? ((hour + 12) % 12 + 'pm') : hour + 'am';
      }
    };

    $scope.chartOptions = {
      axes: { 
        x: {
          key: 'pingHourCreatedAt',
          // ticksFormatter: formatHour,
          type: 'date'
        },
        y: {
          ticksFormatter: function(y) {
            return y + 'ms';
          },
          innerTick: true,
          ticks: 5,
          grid: true
        }
      },
      series: [{
        y: 'averageTransferTimeMs',
        dotSize: 4,
        thickness: '2px'   
      }],
      tooltip: {
        mode: 'scrubber',
        // formatter: function(x, y) {
        //   return formatHour(x) + ': ' + y + 'ms';
        // }
      },
      drawLegend: false,
      lineMode: 'cardinal',
      margin: {
        right: 10,
        bottom: 20,
        // left: 50,
        top: 5
      }
    };

    var updateChart = function() {
      $scope.dataLoading = true;
      fetchHours($scope.origin.name).then(function(data) {
        $scope.chartData = data;
      }).finally(function() {
        $scope.dataLoading = false;
      });
    };

    updateChart();

    $scope.updateOrigin = function($item, $model) {
      $scope.origin = {name: $item.name};
      updateChart();
    };
  }
]);