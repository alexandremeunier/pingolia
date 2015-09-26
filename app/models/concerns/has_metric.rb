# The HasMetrics adds a `has_metric` helper which ensure Metrics are automatically
# recalculated on `after_commit`
module HasMetric
  extend ActiveSupport::Concern

  included do 
    mattr_accessor :registered_metrics do  
      []
    end

    mattr_accessor :auto_recalculate_metrics do
      true
    end

    after_commit :refresh_metrics
  end

  # Refreshes metrics relating to current model instance
  def refresh_metrics
    if self.auto_recalculate_metrics
      if Rails.configuration.async_recalculate_metrics
        MetricsWorker.perform_async(self.id)
      else
        self.registered_metrics.each do |metric| 
          metric.refresh_from_ping(self)
        end
      end
    end
  end

  module ClassMethods
    # Register dependencies to one or multiple Metric classes
    # @param [*Symbol, String] metric_names Splat array of the metric names, 
    #                           using the following convention:
    #                             Metrics::HourlyAverageTransferTime => :hourly_average_transfer_time
    def has_metric *metric_names
      metric_names.each do |metric_name|
        klass = "Metrics::#{metric_name.to_s.camelize}".constantize

        unless klass.respond_to?(:refresh_from_ping) or klass.respond_to?(:refresh_all)
          raise Exception.new("#{klass.name} need to have `:refresh_all` and `:refresh_from_ping` class methods")
        end

        self.registered_metrics << klass
      end
    end
  end
end