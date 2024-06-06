# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :doorkeeper_authorize!

  def show
    user = User.find(params[:id])
    render json: user
  end
end
