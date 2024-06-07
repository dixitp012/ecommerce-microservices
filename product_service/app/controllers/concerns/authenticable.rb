# app/controllers/concerns/authenticate_user.rb
module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    if token && valid_token?(token)
      true
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def valid_token?(token)
    response = HTTP.get("#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token", headers: { Authorization: "Bearer #{token}" })
    response.status == 200
  end
end

  