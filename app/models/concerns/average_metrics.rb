#
# The AverageMetrics concern implements `.refresh_from_ping` and `.refresh_all`
# to make creating Metrics models easier, when those models relate to the calculation
# of a given Ping column (e.g. `transfer_time_ms`) over a given interval (e.g. `hour`)
#
# Configuration is done via the class attributes `average_interval` and
# `average_column_name`.
# 
# See `Metrics::HourlyAverageTransferTime` for an example usage.
module AverageMetrics
  extend ActiveSupport::Concern
  include DateUtils

  included do
    cattr_accessor :average_interval
    cattr_accessor :average_column_name
  end

  module ClassMethods
    def refresh_from_ping(ping)
      date = case average_interval
      when :day
        ping.ping_created_at.change(hour: 0)
      when :hour
        ping.ping_created_at.change(min: 0)
      when :month
        ping.ping_created_at.change(day: 1)
      end

      grouped_pings = Ping
        .for_origin(ping.origin)
        .select_average(average_column_name)
        .select_and_group_by_truncated_date(average_interval)
        .between_dates(date, date + 1.send(average_interval))

      refresh_from_grouped_pings(grouped_pings, ping.origin)
    end

    def refresh_all(ping_relation = Ping.all)
      grouped_pings = ping_relation
        .select_average(average_column_name)
        .select_and_group_by_truncated_date(average_interval)
        .select(:origin)
        .group(:origin)

      refresh_from_grouped_pings(grouped_pings)
    end

    private

      def refresh_from_grouped_pings(grouped_pings, origin = nil)
        grouped_pings.map do |ping_group|
          metric_attrs = {
            origin: origin || ping_group.origin, 
            "ping_created_at_#{average_interval}" => ping_group["ping_created_at_#{average_interval}"]
          }

          metric = self.find_by(metric_attrs) || self.new(metric_attrs)
          metric.send("average_#{average_column_name}=", ping_group["average_#{average_column_name}"])
          metric.save
          metric
        end
      end
  end
end