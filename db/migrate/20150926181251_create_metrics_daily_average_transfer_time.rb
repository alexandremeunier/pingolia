class CreateMetricsDailyAverageTransferTime < ActiveRecord::Migration
  def change
    create_table :metrics_daily_average_transfer_times do |t|
      t.string    :origin, null: false
      t.float     :average_transfer_time_ms, null: false
      t.timestamp :ping_created_at_day, null: false

      t.timestamps

      t.index :origin
      t.index [:origin, :ping_created_at_day], name: 'daily_origin_created_at', unique: true
    end
  end
end
