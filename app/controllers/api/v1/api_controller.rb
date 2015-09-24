class Api::V1::ApiController < ActionController::Base
  respond_to :json
  protect_from_forgery with: :null_session
end