require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['email']).to eq(User.last.email)
      end
    end

    context 'with invalid params' do
      it 'returns an unprocessable entity status' do
        post :create, params: { user: attributes_for(:user, password_confirmation: 'mismatch') }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

