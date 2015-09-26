module Api::V1
  class PingsController < ApiController

    # POST /api/1/pings
    # ---
    # 
    # Creates a ping
    # The data must be provided in the following form:
    # 
    # ```
    # {
    #   ping: {
    #     "origin": "sdn-probe-moscow",
    #     "name_lookup_time_ms": 203,
    #     "connect_time_ms": 413,
    #     "transfer_time_ms": 135,
    #     "total_time_ms": 752,
    #     "created_at": "2015-08-10 21:52:21 UTC",
    #     "status": 200
    # }
    # ```
    # 
    # Returns an array of errors the object was not persisted
    def create
      @ping = Ping.create(create_params)
      respond_with(@ping, location: root_url)
    end

    # GET /api/1/pings/:origin/hours
    # ---
    # 
    # Returns the average `transfer_time_ms` aggregated per hour for a given origin
    # 
    # Additional optional request parameters:
    #   * `before`: [DateTime as String]  max requested value of `ping_created_at`. Defaults to the 
    #                                     actual max value of `ping_created_at`
    #   * `after`: [DateTime as String]   min requested value of  `ping_created_at`. Defaults to a day
    #                                     prior to `before`
    #   * `page`: [Integer]  results page requested
    #   * `per`: [Integer] number of items per request. Defaults to 24
    # 
    # Renders the resulting values along with meta data about the current page
    # and the maximum and minimum values of `ping_created_at` for this origin
    # (regardless of `before` or `after` params)
    # 
    # Example object returned:
    # 
    # ```
    # {
    #   data: [
    #     {
    #       averageValue: 1005,
    #       averageDate: "2015-09-24T00:00:00.000Z"
    #     }, 
    #     ...
    #   ],
    #   meta: {
    #     maxPingCreatedAt: "2015-09-24T08:33:24.000Z",
    #     minPingCreatedAt: "2015-08-24T16:05:31.951Z",
    #     pagination: {
    #       currentPage: 1,
    #       perPage: 100
    #     }
    #   }
    # }
    def hours
      averages(:hour, 24)
    end

    # GET /api/1/pings/:origin/hours
    # ---
    # 
    # Returns the average `transfer_time_ms` aggregated per day for a given origin.
    # 
    # Same as #hours, with the exception of the `per` params which defaults to 30, 
    # and to `after` which defaults to a month prior to `before` 
    def days
      averages(:day, 30)
    end

    # GET /api/1/pings/:origin/hours
    # ---
    # 
    # Returns the average `transfer_time_ms` aggregated per day for a given month
    # 
    # Same as #hours, with the exception of the `per` params which defaults to 30,
    # and to `after` which defaults to a year prior to `before` 
    def months
      averages(:month, 12)
    end

    private


      # Uses strong_parameters to filter request parameters that are used to 
      # create new ping
      def create_params
        create_params = params.require(:ping).permit(
          :origin, :connect_time_ms, :transfer_time_ms,
          :name_lookup_time_ms, :total_time_ms, :status,
          :created_at
        )

        create_params[:ping_created_at] = create_params.delete(:created_at)
        create_params
      end

      # Creates instance variables relating to pings for the selected origin
      def select_pings
        @origin = params[:origin]
        @pings_for_origin = Ping.for_origin(@origin)
        @max_ping_created_at = @pings_for_origin.max_ping_created_at
        @min_ping_created_at = @pings_for_origin.min_ping_created_at
      end

      # Returns `before_date` and `after_date`] values, where both values are derived from 
      # the `before` and `after` request params to conform with the behaviours
      # described above for `#hours`, `#days`, `#months`
      def date_params(interval)
        return nil, nil if @max_ping_created_at.nil? # If max is nil, there are no matching pings

        before_date = if params.include?(:before)
          DateTime.parse(params[:before]) rescue @max_ping_created_at + 1.second
        else
          @max_ping_created_at + 1.second
        end

        after_date_interval = case interval
        when :hour; :day
        when :day; :month
        when :month; :year;
        end

        after_date = if params.include?(:after)
          DateTime.parse(params[:after]) rescue before_date - 1.send(after_date_interval)
        else
          before_date - 1.send(after_date_interval)
        end
        
        return before_date, after_date
      end

      # Selects pings and fetches average transfer_time_ms metrics for a given interval
      # Renders result in JSON
      #
      # @param [Symbol] interval  e.g. `:day`, `:month`, `:hour`
      # @param [Integer] default_per number of results to return unless params[:get] exists
      def averages(interval, default_per)
        select_pings
        
        @before_date, @after_date = date_params(interval)

        interval_for_klass = interval == :day ? :dai : interval
        metrics_klass = "Metrics::#{interval_for_klass.to_s.camelize}lyAverageTransferTime".constantize
      
        @averages = metrics_klass
          .where(origin: @origin)
          .between_dates(@before_date, @after_date)
          .page(params[:page])
          .per(params[:per] || default_per)

        render json: @averages, 
          serializer: PaginatedSerializer,
          each_serializer: PingAverageSerializer,
          average_interval: interval,
          average_column_name: :transfer_time_ms,
          meta: {
            max_ping_created_at: @max_ping_created_at,
            min_ping_created_at: @min_ping_created_at
          }
      end
  end
end