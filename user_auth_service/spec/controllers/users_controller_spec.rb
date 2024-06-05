require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:application) { Doorkeeper::Application.create!(name: 'MicroserviceApp', redirect_uri: 'https://dummy-redirect-uri.com') }
  let!(:token) { Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: user.id, scopes: 'public') }

  describe 'GET #show' do
    context 'with a valid token' do
      it 'returns the user' do
        request.headers['Authorization'] = "Bearer #{token.token}"
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['email']).to eq(user.email)
      end
    end

    context 'without a valid token' do
      it 'returns an unauthorized error' do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
