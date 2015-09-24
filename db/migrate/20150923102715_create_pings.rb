#
# example data: 
# {
#   "origin": "sdn-probe-moscow",
#   "name_lookup_time_ms": 203,
#   "connect_time_ms": 413,
#   "transfer_time_ms": 135,
#   "total_time_ms": 752,
#   "created_at": "2015-08-10 21:52:21 UTC",
#   "status": 200
# }
# 

class CreatePings < ActiveRecord::Migration
  def change
    create_table :pings do |t|
      t.string    :origin, null: false
      t.integer   :connect_time_ms, null: false
      t.integer   :transfer_time_ms, null: false
      t.integer   :name_lookup_time_ms, null: false
      t.integer   :total_time_ms, null: false
      t.integer   :status, null: false
      t.timestamp :ping_created_at, null: false

      t.timestamps

      t.index :origin
      t.index [:origin, :ping_created_at], unique: true
    end
  end
end
