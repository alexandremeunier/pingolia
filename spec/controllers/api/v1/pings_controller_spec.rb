require 'rails_helper'

describe Api::V1::PingsController do 
  let(:origin) { 'origin' }
  let(:today) { Time.at(Time.now.to_i)  } # Solves milliseconds issues

  subject { response }
  describe '#create' do 
    let(:valid_ping_param) do
      { ping: {
        origin: "sdn-probe-moscow",
        name_lookup_time_ms: 203,
        connect_time_ms: 413,
        transfer_time_ms: 135,
        total_time_ms: 752,
        created_at: "2015-08-10 21:52:21 UTC",
        status: 200
      }}
    end

    let(:invalid_ping_param) do 
      { ping: {
        origin: "sdn-probe-moscow",
        name_lookup_time_ms: 203,
        connect_time_ms: 413,
        total_time_ms: 'invalid',
        created_at: "2015-08-10 21:52:21 UTC",
        status: 200
      }}
    end

    it 'should not respond to non-json requests' do 
      expect {
        post :create, valid_ping_param
      }.to raise_error ActionController::UnknownFormat
    end

    context 'when valid params are provided' do 
      before { post :create, valid_ping_param.merge(format: :json) }
      it 'should be persist the ping' do 
        expect(assigns(:ping)).to be_persisted
      end
    end

    context 'when invalid params are provided' do 
      before { post :create, invalid_ping_param.merge(format: :json) }
      it 'should not persist the ping' do 
       expect(assigns(:ping)).to_not be_persisted
      end
      it { expect(response.status).to be 422 }
      it 'should respond with the errors' do
        expect(response.body).to be == "{\"errors\":{\"transfer_time_ms\":[\"is not a number\"],\"total_time_ms\":[\"is not a number\"]}}"
      end
    end
  end

  describe '#select_pings' do

    before do
      create(:ping, origin: origin)
      Ping.stub(:for_origin) { Ping }
      Ping.stub(:max_ping_created_at) { today }
      Ping.stub(:min_ping_created_at) { today - 1.day }
      get :hours, {origin: origin}
    end

    it 'should create a correct @pings_for_origin instance variable' do
      expect(assigns(:pings_for_origin)).to_not be_nil
      expect(Ping).to have_received(:for_origin).with(origin)
    end

    it 'should create a correct @max_ping_created_at instance variable' do
      expect(assigns(:max_ping_created_at)).to be == today
    end

    it 'should create a correct @min_ping_created_at instance variable' do
      expect(assigns(:min_ping_created_at)).to be == today - 1.day
    end
  end

  describe '#date_params' do 
    context 'when there are no ping' do 
      it 'should return nil values' do 
        get :hours, {origin: origin}
        expect(assigns(:before_date)).to be_nil
        expect(assigns(:after_date)).to be_nil
      end
    end

    context 'when there are pings' do 
      before { create(:ping, origin: origin) }

      context 'when no before or after params are provided' do 
        it 'should assign the correct values' do 
          get :hours, {origin: origin}
          expect(assigns(:before_date)).to be == assigns(:max_ping_created_at) + 1.second
          expect(assigns(:after_date)).to be == assigns(:max_ping_created_at) + 1.second - 1.day
        end
      end

      context 'when a valid before param is provided' do 
        it 'should assign the correct values' do 
          get :hours, {origin: origin, before: today.to_i}
          expect(assigns(:before_date)).to be == today
          expect(assigns(:after_date)).to be == today - 1.day
        end
      end

      context 'when an invalid before param is provided' do 
        it 'should assign the correct values' do 
          get :hours, {origin: origin, before: 'INVALID DATE'}
          expect(assigns(:before_date)).to be == assigns(:max_ping_created_at) + 1.second
          expect(assigns(:after_date)).to be == assigns(:max_ping_created_at) + 1.second - 1.day
        end
      end

      context 'when only an after param is provided' do 
        it 'should assign the correct values' do 
          get :hours, {origin: origin, after: today.to_i}
          expect(assigns(:before_date)).to be == assigns(:max_ping_created_at) + 1.second
          expect(assigns(:after_date)).to be == today
        end
      end

      context 'when both before and after params are provided' do 
        it 'should assign the correct values' do 
          get :hours, {origin: origin, after: (today - 1.day).to_i, before: today.to_i}
          expect(assigns(:before_date)).to be == today
          expect(assigns(:after_date)).to be == today - 1.day
        end
      end
    end
  end
end