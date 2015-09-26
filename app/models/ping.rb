class Ping < ActiveRecord::Base
  validates_presence_of :origin
  validates_numericality_of :connect_time_ms, :transfer_time_ms,
        :name_lookup_time_ms, :total_time_ms, :status

  # Shortcut scope to filter by origin
  # @param [String] origin_name Name of origin to filter
  scope :for_origin, ->(origin_name) do 
    self.where(origin: origin_name)
  end

  # Shortcut scope to filter ping_created_at between to give date (exclusive of the highest)
  # @param [DateTime] date1 _(included in results)_
  # @param [DateTime] date2 _(excluded from results)_
  scope :between_dates, ->(date1, date2) do 
    self.where(
      "pings.ping_created_at >= ? AND pings.ping_created_at < ?", 
      [date1, date2].min, 
      [date1, date2].max
    )
  end

  # Shortcut scope to filter ping_created_at before a given date (excluded from selection)
  # @param [DateTime] date _(excluded from results)_
  scope :before_date, ->(date) do 
    self.where('pings.ping_created_at < ?', date)
  end

  # Shortcut scope to filter ping_created_at after a given date (included in selection)
  # @param [DateTime] date _(included in results)_
  scope :after_date, ->(date) do 
    self.where('pings.ping_created_at >= ?', date)
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

  # Adds a select and group by clause to the current query, 
  # corresponding to the value of ping_created_at truncated to the hour
  # @return [ActiveRecord::Relation] Updated query. Once query is executed, 
  #                                  the method +"ping_hour_created_at"+ gives
  #                                  access to the value for each item in the relation
  scope :select_and_group_by_ping_hour_created_at, ->() do 
    self
      .select('DATE_TRUNC(\'hour\', pings.ping_created_at) AS ping_hour_created_at')
      .group('ping_hour_created_at')
      .order('ping_hour_created_at DESC')
  end

  def self.max_ping_created_at
    self.reorder('pings.ping_created_at DESC').limit(1).pluck(:ping_created_at).first
  end

  def self.min_ping_created_at
    self.reorder('pings.ping_created_at ASC').limit(1).pluck(:ping_created_at).first
  end
end