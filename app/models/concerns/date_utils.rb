# The DateUtils concerns adds convenience scopes relating to the `self.primary_date_attr`
# timestamp column
module DateUtils
  extend ActiveSupport::Concern

  included do
    cattr_accessor :primary_date_attr

    # Convenience scope to filter `#{primary_date_attr}` between to give date (exclusive of the highest)
    # @param [DateTime] date1 _(included in results)_
    # @param [DateTime] date2 _(excluded from results)_
    scope :between_dates, ->(date1, date2) do 
      self.where(
        "#{primary_date_attr} >= ? AND #{primary_date_attr} < ?", 
        [date1, date2].min, 
        [date1, date2].max
      )
    end

    # Convenience scope to filter `#{primary_date_attr}` before a given date (excluded from selection)
    # @param [DateTime] date _(excluded from results)_
    scope :before_date, ->(date) do 
      self.where("#{primary_date_attr} < ?", date)
    end

    # Convenience scope to filter `#{primary_date_attr}` after a given date (included in selection)
    # @param [DateTime] date _(included in results)_
    scope :after_date, ->(date) do 
      self.where("#{primary_date_attr} >= ?", date)
    end

    # Adds a select and group by clause to the current query, 
    # corresponding to the value of `#{primary_date_attr}` truncated to a give interval
    # @param [Symbol, String] interval e.g. `:hour`, `:day`
    # @return [ActiveRecord::Relation] Updated query. Once query is executed, 
    #                                  the method +"#{primary_date_attr}_#{interval}"+ gives
    #                                  access to the value for each item in the relation
    scope :select_and_group_by_truncated_date, ->(interval) do
      attr_name = "#{primary_date_attr}_#{interval}"
      self
        .select("DATE_TRUNC(\'#{interval}\', #{primary_date_attr}) AS #{attr_name}")
        .group(attr_name)
        .order("#{attr_name} DESC")
    end
  end
end