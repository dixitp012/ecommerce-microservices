# frozen_string_literal: true

namespace :token do
  desc "Generate an access token"
  task generate: :environment do
    application = Doorkeeper::Application.find_by(name: "MicroserviceApp") || Doorkeeper::Application.create!(name: "MicroserviceApp", redirect_uri: "urn:ietf:wg:oauth:2.0:oob")
    access_token = Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: nil, scopes: "public")
    puts "Generated access token: #{access_token.token}"
  end
end
