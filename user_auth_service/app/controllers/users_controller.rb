# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :doorkeeper_authorize!

  def fetch_user
    user = User.find(doorkeeper_token.resource_owner_id)
    render json: user
  end
end
