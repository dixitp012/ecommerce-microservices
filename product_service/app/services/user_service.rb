# frozen_string_literal: true

class UserService
  def initialize
    @token = ENV["USER_AUTH_SERVICE_TOKEN"]
    @base_url = ENV["USER_AUTH_SERVICE_URL"]
  end

  def fetch_user(user_id)
    response = HTTP.auth("Bearer #{@token}")
                    .get("#{@base_url}/api/v1/users/#{user_id}")
    handle_response(response)
  end

  private
    def handle_response(response)
      if response.status.success?
        JSON.parse(response.body.to_s)
      else
        { error: response.body.to_s }
      end
    end
end
