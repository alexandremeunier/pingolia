# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150926181251) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "metrics_daily_average_transfer_times", force: :cascade do |t|
    t.string   "origin",                   null: false
    t.float    "average_transfer_time_ms", null: false
    t.datetime "ping_created_at_day",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics_daily_average_transfer_times", ["origin", "ping_created_at_day"], name: "daily_origin_created_at", unique: true, using: :btree
  add_index "metrics_daily_average_transfer_times", ["origin"], name: "index_metrics_daily_average_transfer_times_on_origin", using: :btree

  create_table "metrics_hourly_average_transfer_times", force: :cascade do |t|
    t.string   "origin",                   null: false
    t.float    "average_transfer_time_ms", null: false
    t.datetime "ping_created_at_hour",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics_hourly_average_transfer_times", ["origin", "ping_created_at_hour"], name: "origin_created_at", unique: true, using: :btree
  add_index "metrics_hourly_average_transfer_times", ["origin"], name: "index_metrics_hourly_average_transfer_times_on_origin", using: :btree

  create_table "metrics_monthly_average_transfer_times", force: :cascade do |t|
    t.string   "origin",                   null: false
    t.float    "average_transfer_time_ms", null: false
    t.datetime "ping_created_at_month",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics_monthly_average_transfer_times", ["origin", "ping_created_at_month"], name: "monthly_origin_created_at", unique: true, using: :btree
  add_index "metrics_monthly_average_transfer_times", ["origin"], name: "index_metrics_monthly_average_transfer_times_on_origin", using: :btree

  create_table "pings", force: :cascade do |t|
    t.string   "origin",              null: false
    t.integer  "connect_time_ms",     null: false
    t.integer  "transfer_time_ms",    null: false
    t.integer  "name_lookup_time_ms", null: false
    t.integer  "total_time_ms",       null: false
    t.integer  "status",              null: false
    t.datetime "ping_created_at",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pings", ["origin", "ping_created_at"], name: "index_pings_on_origin_and_ping_created_at", unique: true, using: :btree
  add_index "pings", ["origin"], name: "index_pings_on_origin", using: :btree

end
