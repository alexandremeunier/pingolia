class PingAverageTransferTimeByHourSerializer < ApplicationSerializer
  attributes :average_transfer_time_ms
  attributes :ping_hour_created_at
end