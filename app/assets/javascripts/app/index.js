//= require_self
//= require angular-rails-templates
//= require_tree ./config
//= require_tree ./templates
//= require_tree ./services
//= require_tree ./directives
//= require_tree ./controllers

angular.module('dependencies', [
  'restangular',
  'n3-line-chart',
  'ui.router',
  'ui.select',
  'ngSanitize',
  'ui.bootstrap'
]);

var app = angular.module('app', [
  'dependencies',
  'templates'
]);
