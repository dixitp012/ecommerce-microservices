# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      access_token = Doorkeeper::AccessToken.create!(
        resource_owner_id: user.id,
        scopes: "public",
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        use_refresh_token: true
      )
      render json: {
        access_token: access_token.token,
        token_type: "Bearer",
        expires_in: access_token.expires_in,
        refresh_token: access_token.refresh_token,
        user_id: user.id
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
