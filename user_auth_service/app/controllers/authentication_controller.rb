# frozen_string_literal: true

# app/controllers/authentication_controller.rb
class AuthenticationController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:validate_token]

  def validate_token
    render json: { valid: true }, status: :ok
  end
end
