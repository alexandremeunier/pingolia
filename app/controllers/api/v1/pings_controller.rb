module Api::V1
  class PingsController < ApiController
    def create
      @ping = Ping.create(create_params)
      respond_with(@ping, location: root_url)
    end

    def hours
      origin = params[:origin]
      pings_for_origin = Ping.for_origin(origin)

      after_date = params[:after_date] || pings_for_origin.max_ping_created_at + 1.second
      before_date = params[:before_date] || after_date - 1.day
      
      @averages = pings_for_origin
        .between_dates(before_date, after_date)
        .select_average(:transfer_time_ms)
        .select_and_group_by_ping_hour_created_at

      respond_with(@averages)
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
  end
end