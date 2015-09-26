module Api::V1
  class PingsController < ApiController
    def create
      @ping = Ping.create(create_params)
      respond_with(@ping, location: root_url)
    end

    def hours
      select_pings
      
      @before_date, @after_date = date_params
    
      @averages = Metrics::HourlyAverageTransferTime
        .where(origin: @origin)
        .between_dates(@before_date, @after_date)
        .page(params[:page])
        .per(24)

      render json: @averages, 
        serializer: PaginatedSerializer,
        each_serializer: PingAverageTransferTimeByHourSerializer,
        meta: {
          max_ping_created_at: @max_ping_created_at,
          min_ping_created_at: @min_ping_created_at
        }
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

      def date_params
        return nil, nil if @max_ping_created_at.nil? # If max is nil, there are no matching pings


        before_date = if params.include?(:before)
          DateTime.parse(params[:before]) rescue @max_ping_created_at + 1.second
        else
          @max_ping_created_at + 1.second
        end

        after_date = if params.include?(:after)
          DateTime.parse(params[:after]) rescue before_date - 1.day
        else
          before_date - 1.day
        end
        
        return before_date, after_date
      end
  end
end