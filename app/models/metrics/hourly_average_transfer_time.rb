class Metrics::HourlyAverageTransferTime < ActiveRecord::Base
  include AverageMetrics
  self.primary_date_attr = :ping_created_at_hour
  self.average_column_name = :transfer_time_ms
  self.average_interval = :hour
end