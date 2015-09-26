class MetricsWorker
  include Sidekiq::Worker

  def perform(ping_id)
    ping = Ping.find(ping_id)

    if ping
      ping.registered_metrics.each do |metric|
        metric.refresh_from_ping(ping)
      end
    end
  end
end