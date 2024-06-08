# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "Orders API", type: :request do
  let!(:orders) { create_list(:order, 5) }
  let(:order_id) { orders.first.id }
  let(:user_id) { SecureRandom.uuid }
  let(:product_id) { SecureRandom.uuid }
  let(:headers) { { "Content-Type" => "application/json", "Authorization" => "Bearer valid_token" } }
  let(:invalid_headers) { { "Content-Type" => "application/json", "Authorization" => "Bearer invalid_token" } }

  before do
    stub_request(:get, "#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token")
      .with(headers: { 'Authorization' => 'Bearer valid_token' })
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token")
      .with(headers: { 'Authorization' => 'Bearer invalid_token' })
      .to_return(status: 401, body: '{"error":"Unauthorized"}', headers: {})
  end

  # Test suite for GET /api/v1/orders
  describe 'GET /api/v1/orders' do
    context 'with valid token' do
      before { get '/api/v1/orders', headers: headers }

      it 'returns orders' do
        expect(json).not_to be_empty
        expect(json.size).to eq(5)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid token' do
      before { get '/api/v1/orders', headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for GET /api/v1/orders/:id
  describe 'GET /api/v1/orders/:id' do
    context 'with valid token' do
      context 'when the record exists' do
        before { get "/api/v1/orders/#{order_id}", headers: headers }

        it 'returns the order' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(order_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        let(:order_id) { SecureRandom.uuid }

        before { get "/api/v1/orders/#{order_id}", headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Order/)
        end
      end
    end

    context 'with invalid token' do
      before { get "/api/v1/orders/#{order_id}", headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for POST /api/v1/orders
  describe 'POST /api/v1/orders' do
    let(:valid_attributes) { { user_id: user_id, line_items_attributes: [{ product_id: product_id, quantity: 2, price_cents: 1000 }] }.to_json }

    context 'with valid token' do
      context 'when the request is valid' do
        before { post '/api/v1/orders', params: valid_attributes, headers: headers }

        it 'creates an order' do
          expect(json['user_id']).to eq(user_id)
          expect(json['line_items'].first['product_id']).to eq(product_id)
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid' do
        let(:invalid_attributes) { { user_id: nil, line_items_attributes: [{ product_id: product_id, quantity: 2, price_cents: 1000 }] }.to_json }
        before { post '/api/v1/orders', params: invalid_attributes, headers: headers }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body).to match(/can't be blank/)
        end
      end
    end

    context 'with invalid token' do
      before { post '/api/v1/orders', params: valid_attributes, headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for PUT /api/v1/orders/:id
  describe 'PUT /api/v1/orders/:id' do
    let(:valid_attributes) { { user_id: user_id, line_items_attributes: [{ product_id: product_id, quantity: 2, price_cents: 1000 }] }.to_json }

    context 'with valid token' do
      context 'when the record exists' do
        before { put "/api/v1/orders/#{order_id}", params: valid_attributes, headers: headers }

        it 'updates the record' do
          expect(json['user_id']).to eq(user_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        let(:order_id) { SecureRandom.uuid }

        before { put "/api/v1/orders/#{order_id}", params: valid_attributes, headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Order/)
        end
      end
    end

    context 'with invalid token' do
      before { put "/api/v1/orders/#{order_id}", params: valid_attributes, headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for DELETE /api/v1/orders/:id
  describe 'DELETE /api/v1/orders/:id' do
    context 'with valid token' do
      before { delete "/api/v1/orders/#{order_id}", headers: headers }

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'with invalid token' do
      before { delete "/api/v1/orders/#{order_id}", headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end
end
