class PingAverageTransferTimeByHourSerializer < ApplicationSerializer
  attributes :average_transfer_time_ms
  attributes :ping_created_at_hour
end