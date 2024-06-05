require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password') }

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'returns an access token' do
        post :create, params: { email: 'test@example.com', password: 'password' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['access_token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized error' do
        post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end
end
