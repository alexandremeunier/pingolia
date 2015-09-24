require 'rails_helper'

describe 'Api::V1 routes' do 
  it 'should respond to POST /api/1/pings' do 
    expect(post: 'api/1/pings').to route_to({
      controller: 'api/v1/pings',
      action: 'create'
    })
  end

  it 'should respond to GET /api/1/pings/:origin/hours' do 
    expect(get: 'api/1/pings/paris/hours').to route_to({
      controller: 'api/v1/pings',
      action: 'hours',
      origin: 'paris'
    })
  end
end