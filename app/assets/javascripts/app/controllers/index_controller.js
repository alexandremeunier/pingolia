var app = angular.module('app');

app.config([
  '$stateProvider',
  function($stateProvider) {
    $stateProvider.state('index', {
      url: '?origin&date',
      templateUrl: 'index.html',
      controller: 'IndexController'
    });
  }
]);

app.controller('IndexController', [
  '$scope', 'fetchAverages', '$stateParams', '$state',
  function($scope, fetchHours, $stateParams, $state) {
    $scope.availableOrigins = _.map(window.AVAILABLE_ORIGINS, function(origin) {
      return {
        name: origin
      };
    });
    $scope.origin = _.findWhere($scope.availableOrigins, {name: $stateParams.origin}) ||
      $scope.availableOrigins[0];
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
      lineMode: 'monotone',
      margin: {
        right: 10,
        bottom: 20,
        // left: 50,
        top: 5
      }
    };

    var updateChart = function() {
      $scope.dataLoading = true;
      fetchHours($scope.origin.name, {
        before: $scope.chartStartDate && Math.floor(+$scope.chartStartDate/1000)
      }).then(function(data) {
        $scope.chartData = data;
        $scope.datepicker.minDate = new Date(data.meta.minPingCreatedAt);
        $scope.datepicker.maxDate = new Date(data.meta.maxPingCreatedAt);
      }).finally(function() {
        $scope.dataLoading = false;
      });
    };

    $scope.updateOrigin = function($item, $model) {
      $scope.origin = {name: $item.name};
      $scope.chartStartDate = undefined;
      $state.go('.', {origin: $item.name, date: undefined}, {notify: false});
      updateChart();
    };

    if(!_.isUndefined($stateParams.date)) { 
      $scope.chartStartDate = new Date(Number($stateParams.date));
    }
    $scope.datepicker = {
      opened: false
    };
    $scope.openDatepicker = function($event) {
      $event.preventDefault
      $scope.datepicker.opened = !$scope.datepicker.opened;
    }
    $scope.$watch('chartStartDate', function(newVal, oldVal) {
      if(oldVal === newVal) return;
      var date = newVal && +newVal;
      $state.go('.', {date: date}, {notify: false})
      updateChart();
    })

    updateChart();
  }
]);