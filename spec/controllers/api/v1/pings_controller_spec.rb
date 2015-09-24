require 'rails_helper'

describe Api::V1::PingsController do 
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
end