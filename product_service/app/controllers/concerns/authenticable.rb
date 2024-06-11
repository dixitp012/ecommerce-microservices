# frozen_string_literal: true

# app/controllers/concerns/authenticate_user.rb
module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, unless: :public_route?
  end

  private
    def authenticate_user!
      token = request.headers["Authorization"]&.split(" ")&.last

      if token && valid_token?(token)
        true
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def valid_token?(token)
      response = HTTP.get("#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token", headers: { Authorization: "Bearer #{token}" })
      response.status == 200
    end

    def public_route?
      health_check? || product_routes?
    end

    def health_check?
      controller_name == "health" && action_name == "show"
    end

    def product_routes?
      controller_name == "products" && %w[index show].include?(action_name)
    end
end
