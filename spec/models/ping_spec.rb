require 'rails_helper'

describe Ping do
  def ary_average(ary) 
    (ary.reduce(0.0) { |memo, el| memo + el } / ary.size).round(3)
  end


  let(:random_pings) { create_list(:ping, 5) }
  let(:abc_pings) { create_list(:ping, 3, origin: 'abc')}
  let(:today) { Time.now }
  let(:pings_today_at_9am) { create_list(:ping, 3, same_hour_as: today.change(hour: 9)) }  
  let(:pings_yesterday_at_10am) { create_list(:ping, 3, same_hour_as: today.change(hour: 10) - 1.day) }

  describe '.for_origin' do 
    before do
      random_pings
      abc_pings
    end
    
    it 'should have created all pings' do
      expect(Ping.count).to be 8
    end

    it 'should return only `abc` pings' do 
      expect(Ping.for_origin('abc').count).to be 3
    end
  end

  describe '.between_dates' do 
    let!(:ping0) { create(:ping, ping_created_at: today) }
    let!(:ping1) { create(:ping, ping_created_at: today - 1.second)}
    let!(:ping2) { create(:ping, ping_created_at: today - 2.seconds)}
    let!(:ping3) { create(:ping, ping_created_at: today - 3.seconds)}
    it 'should select the correct values' do 
      pings = Ping.between_dates(today - 1.second, today - 3.second)
      expect(pings).to_not include ping1
      expect(pings).to include ping2
      expect(pings).to include ping3
    end
  end

  describe '.select_average' do 
    let(:transfer_times) { [100, 150, 200, 500] }
    let(:ping_with_transfer_times) do 
      transfer_times.map { |t| create(:ping, transfer_time_ms: t) } 
    end

    it 'should return the correct value' do 
      ping_with_transfer_times
      expected_average = ary_average(transfer_times)
      expect(Ping.select_average(:transfer_time_ms)[0].average_transfer_time_ms).to be expected_average
    end

    it 'should work in combination with scopes' do
      origin = ping_with_transfer_times.first.origin
      average = Ping.for_origin(origin).select_average(:transfer_time_ms)[0].average_transfer_time_ms
      expected_average = ary_average(Ping.for_origin(origin).map(&:transfer_time_ms))
      expect(average).to be == expected_average
    end
  end

  describe '.select_and_group_by_ping_hour_created_at' do 
    subject { Ping.select_and_group_by_ping_hour_created_at }
    before do
      pings_today_at_9am
      pings_yesterday_at_10am
    end

    it 'should group the rows correctly' do 
      expect(subject.to_a.count).to be 2
    end

    it 'should have the correct ping_hour_created_at values' do 
      values = subject.map do |grouped_ping|
        grouped_ping.ping_hour_created_at.change(min: 0)
      end

      expect(values).to include today.change(hour: 9)
      expect(values).to include (today - 1.day).change(hour: 10)
    end
  end
end