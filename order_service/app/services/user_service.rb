# frozen_string_literal: true

class UserService
  def initialize
    @base_url = ENV["USER_AUTH_SERVICE_URL"]
  end

  def fetch_user(user_token)
    response = HTTP.auth("Bearer #{user_token}")
                    .get("#{@base_url}/api/v1/users/fetch_user")
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
