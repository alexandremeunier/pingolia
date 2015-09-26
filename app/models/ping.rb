class Ping < ActiveRecord::Base
  validates_presence_of :origin
  validates_numericality_of :connect_time_ms, :transfer_time_ms,
        :name_lookup_time_ms, :total_time_ms, :status

  include HasMetric
  has_metric :hourly_average_transfer_time

  include DateUtils
  self.primary_date_attr = :ping_created_at

  # Shortcut scope to filter by origin
  # @param [String] origin_name Name of origin to filter
  scope :for_origin, ->(origin_name) do 
    self.where(origin: origin_name)
  end

  # Adds a select clause to the current query, corresponding to the average value of 
  # a given column for that query
  # @param [Symbol,  String] column_name Name of column on which to compute the average
  # @return [ActiveRecord::Relation]  Updated query. Once query is executed, 
  #                                   the method +"average_#{column_name}"+ gives
  #                                   access to the value for each item in the relation
  scope :select_average, ->(column_name) do 
    self.select("AVG(pings.#{column_name})::REAL AS average_#{column_name}")
  end

  # @return [DateTime] Max value of `ping_created_at` for the current relation
  def self.max_ping_created_at
    self.reorder('pings.ping_created_at DESC').limit(1).pluck(:ping_created_at).first
  end

  # @return [DateTime] Min value of `ping_created_at` for the current relation
  def self.min_ping_created_at
    self.reorder('pings.ping_created_at ASC').limit(1).pluck(:ping_created_at).first
  end
end