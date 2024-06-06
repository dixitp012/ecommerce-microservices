# frozen_string_literal: true

class RegistrationsController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

    private
      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
end
