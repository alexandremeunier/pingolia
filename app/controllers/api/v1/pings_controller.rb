module Api::V1
  class PingsController < ApiController
    def create
      @ping = Ping.create(create_params)
      respond_with(@ping, location: root_url)
    end

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

    def hours
      averages(:hour, 24)
    end

    def days
      averages(:day, 30)
    end

    def months
      averages(:month, 12)
    end

    private

      def create_params
        create_params = params.require(:ping).permit(
          :origin, :connect_time_ms, :transfer_time_ms,
          :name_lookup_time_ms, :total_time_ms, :status,
          :created_at
        )

        create_params[:ping_created_at] = create_params.delete(:created_at)
        create_params
      end

      def select_pings
        @origin = params[:origin]
        @pings_for_origin = Ping.for_origin(@origin)
        @max_ping_created_at = @pings_for_origin.max_ping_created_at
        @min_ping_created_at = @pings_for_origin.min_ping_created_at
      end

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
  end
end