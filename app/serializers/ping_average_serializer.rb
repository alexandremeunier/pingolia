class PingAverageSerializer < ApplicationSerializer
  attributes :average_value
  attributes :average_date

  def average_value
    object.send("average_#{options[:average_value] || :transfer_time_ms}")
  end

  def average_date
    object.send(object.primary_date_attr)
  end
end