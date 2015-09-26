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
  '$scope', 'fetchData', '$stateParams', '$state',
  function($scope, fetchData, $stateParams, $state) {
    // Available origins list is extracted from window namespaced (inserted via rails view)
    $scope.availableOrigins = _.map(window.AVAILABLE_ORIGINS, function(origin) {
      return {
        name: origin
      };
    });
    $scope.origin = _.findWhere($scope.availableOrigins, {name: $stateParams.origin}) ||
      $scope.availableOrigins[0];

    // Default values
    $scope.chartData = [];
    $scope.timelineData = [];

    // Main chart options
    var tooltipDateFormatter = d3.time.format('%b %d %I%p');
    $scope.chartOptions = {
      axes: { 
        x: {
          key: 'averageDate',
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
        y: 'averageValue',
        dotSize: 4,
        thickness: '2px'   
      }],
      tooltip: {
        mode: 'scrubber',
        formatter: function(x, y) {
          return tooltipDateFormatter(x) + ': ' + y + 'ms';
        }
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


    // Timeline chart options
    $scope.timelineOptions = {
      axes: { 
        x: {
          key: 'averageDate',
          // ticksFormatter: formatHour,
          type: 'date',
          ticks: 4
        },
        y: {
          min: 0,
          ticksFormatter: function() { return ''; },
          ticks: 0
        }
      },
      series: [{
        y: 'averageValue',
        type: 'area',
        thickness: '0px',
        drawDots: false
      }, {
        y: 'cursorValue',
        type: 'line',
        thickness: '2px',
        dotSize: 5
      }],
      tooltip: {
        mode: 'none'
      },
      drawLegend: false,
      lineMode: 'monotone',
      margin: {
        right: 20,
        bottom: 30,
        left: 20,
        top: 20
      }
    };


    // Handles displaying and updating the "cursor" in the timeline view (corresponding)
    // to the currently selected date in main chart

    var previousCursorDate;
    var findCursorIndex = function(date) {
      return _.findIndex($scope.timelineData, function(datapoint) {
        var newDate = new Date(datapoint.averageDate);
        newDate.setHours(0, 0, 0, 0);
        return +newDate === +date;
      });
    };

    var updateCursor = function(newCursorDate) {
      newCursorDate.setHours(0, 0, 0, 0);
      if(!_.isUndefined(previousCursorDate)) {
        var oldIndex = findCursorIndex(previousCursorDate);
        if(oldIndex > -1) {
          delete $scope.timelineData[oldIndex].cursorValue;
        }
      }

      var index = findCursorIndex(newCursorDate);
      if(index > -1) {
        $scope.timelineData[index].cursorValue = $scope.timelineData[index].averageValue;
      } 
      previousCursorDate = newCursorDate;
    };

    // Fetches data and updates timeline chat
    $scope.timelineDataLoading = true;
    var updateTimeline = function() {
      $scope.timelineDataLoading = true;
      return fetchData('days', $scope.origin.name, {
        before: new Date(+$scope.datepicker.maxDate + 1000),
        after: $scope.datepicker.maxDate - 3 * 30 * 24 * 3600 * 1000, // Fetches 3 months of data
        per: 100
      }).then(function(data) {
        $scope.timelineData = data;
      }).finally(function() {
        $scope.timelineDataLoading = false;
      });
    };


    // Fetches data and updates main chart. Triggers cursor and timeline update
    // as necessary. Also populates datepicker range. 
    var updateChart = function(doUpdateTimeline) {
      if(_.isUndefined(doUpdateTimeline)) doUpdateTimeline = false;
      $scope.dataLoading = true;
      fetchData('hours', $scope.origin.name, {
        before: $scope.chartStartDate && new Date(+$scope.chartStartDate + 24 * 3600 * 1000)
      }).then(function(data) {
        $scope.chartData = data;
        $scope.datepicker.minDate = new Date(data.meta.minPingCreatedAt);
        $scope.datepicker.maxDate = new Date(data.meta.maxPingCreatedAt);

        var newCursorDate = $scope.chartStartDate ? 
          new Date($scope.chartStartDate) : 
          new Date(data[data.length - 1].averageDate);

        if(doUpdateTimeline || !$scope.timelineData.length) {
          updateTimeline().then(function() {
            updateCursor(newCursorDate);
          });
        } else {
          updateCursor(newCursorDate);
        }
      }).finally(function() {
        $scope.dataLoading = false;
      });
    };

    // Triggered when origin is changed via dropdown
    $scope.updateOrigin = function($item) {
      $scope.origin = {name: $item.name};
      $scope.chartStartDate = undefined;
      $state.go('.', {origin: $item.name, date: undefined}, {notify: false});
      updateChart(true);
    };


    // Datepicker configuration and behaviour
    if(!_.isUndefined($stateParams.date)) { 
      $scope.chartStartDate = new Date(Number($stateParams.date));
    }
    $scope.datepicker = {
      opened: false
    };
    $scope.openDatepicker = function($event) {
      $event.preventDefault();
      $scope.datepicker.opened = !$scope.datepicker.opened;
    };
    $scope.$watch('chartStartDate', function(newVal, oldVal) {
      if(oldVal === newVal) {
        return;
      }
      var date = newVal && +newVal;
      $state.go('.', {date: date}, {notify: false});
      updateChart();
    });


    // Bootstrap chart
    updateChart();
  }
]);