class Metrics::DailyAverageTransferTime < ActiveRecord::Base
  include AverageMetrics
  self.primary_date_attr = :ping_created_at_day
  self.average_column_name = :transfer_time_ms
  self.average_interval = :day
end