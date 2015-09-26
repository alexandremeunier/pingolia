# Pingolia

## Demo

A live version of the app is available at https://pingolia-am.herokuapp.com/. 

## Running in development

1. Clone repo
1. Ensure you are running the correct version of ruby (`~2.2`) and have bundler installed (`gem install bundler`), postgres installed and running
1. Install gem dependencies `bundle`
1. Install bower dependencies `bundle exec rake bower:install`
1. Create the database and seed it `bundle exec rake db:create db:migrate db:seed`. _Note: `pings.json` must be copied to the repo root_
1. Launch the development server `foreman start web`

## Rationale behind the `Metrics::*` models

The purpose of the `Metrics::*` models (e.g. `Metrics::HourlyAverageTransferTime`) is to preprocess and cache metrics calculated on underlying Ping attributes. 

A preliminary version of the app, closer to the initial spec, was developed using uncached PG aggregate functions to calculage the aggregated average transfer time [(8673a10)](https://github.com/alexandremeunier/pingolia/commit/8673a1075aafc11e1eabc403345bdc8fc2b6289f).

While this is a worthwhile solution, the `Metrics` model allows us to decorrelate as much as possible the API get requests' response time from the number of underlying objects needed to compute each metrics value. 

As an example, the demo application also calculates daily and monthly average `transfer_time_ms`. Daily values are used in the timeline beneath the main chart. Calculating those values in real time would greatly decrease the performance and UX of the charts.

To remove the calculation load from the POST requests, metrics are preprocessed in parallel in a sidekiq worker.



