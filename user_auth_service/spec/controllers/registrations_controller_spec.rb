require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        post :create, params: attributes_for(:user)
        expect(response).to have_http_status(:created)
        expect(User.count).to eq(1)
      end
    end

    context 'with invalid params' do
      it 'returns an unprocessable entity status' do
        post :create, params: attributes_for(:user, password_confirmation: 'mismatch')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
