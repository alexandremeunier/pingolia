
#   "origin": "sdn-probe-moscow", 
#   "name_lookup_time_ms": 203, 
#   "connect_time_ms": 413, 
#   "transfer_time_ms": 135, 
#   "total_time_ms": 752, 
#   "created_at": "2015-08-10 21:52:21 UTC",
#   "status": 200
# }

ORIGINS = %w(austria milano london paris brisbane vienna tokyo seoul)



def generate_date_at_given_hour(hour)
  generate_previous_date.change(hour: hour)
end

FactoryGirl.define do 
  sequence(:time_ms) do 
    Random.rand(1500)
  end

  sequence(:origin) do 
    ORIGINS.sample
  end 

  sequence(:previous_date) do 
    Time.now - Random.rand(12 * 30 * 24 * 60).minutes
  end

  factory :ping do 
    origin                { generate(:origin) }
    name_lookup_time_ms   { generate(:time_ms) }
    connect_time_ms       { generate(:time_ms) }
    transfer_time_ms      { generate(:time_ms) }
    total_time_ms         { generate(:time_ms) }
    status                200

    transient do
      same_hour_as nil
    end

    ping_created_at do
      same_hour_as.nil? ? 
        generate(:previous_date) : 
        same_hour_as.change(minute: 0) + Random.rand(60 * 60 - 1)
    end

  end
end