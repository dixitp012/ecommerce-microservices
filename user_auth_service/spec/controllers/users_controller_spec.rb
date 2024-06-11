# spec/controllers/users_controller_spec.rb

require 'rails_helper'
require 'doorkeeper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { create(:access_token, application: nil, resource_owner_id: user.id) }

  describe 'GET #fetch_user' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = "Bearer #{token.token}"
        get :fetch_user
      end

      it 'returns the user' do
        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(user.id)
        expect(json['email']).to eq(user.email)
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = "Bearer invalid_token"
        get :fetch_user
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'without token' do
      before do
        get :fetch_user
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
