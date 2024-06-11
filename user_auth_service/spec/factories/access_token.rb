FactoryBot.define do
    factory :access_token, class: 'Doorkeeper::AccessToken' do
      resource_owner_id { create(:user).id }
      token { SecureRandom.hex(32) }
      scopes { 'public' }
      expires_in { 2.hours }
    end
  end
  