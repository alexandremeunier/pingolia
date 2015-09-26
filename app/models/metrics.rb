# Models in the Metrics namespace are intended to correspond to tables of preprocessed
# ping metrics. For instance, hourly average of transfer_time_ms, 
# monthly average of total_time_ms, etc
# 
# Models should have at least an origin column, an "average_#{column_name}"
# for the calculation value, and a timestamp
# 
# Models should also implement 2 idempotent class methods: 
# * refresh_from_ping
# * refresh_all
# 
# See `AverageMetrics` concern and `Metrics::HourlyAverageTransferTime` model
# for an example
module Metrics
  def self.table_name_prefix
    'metrics_'
  end
end