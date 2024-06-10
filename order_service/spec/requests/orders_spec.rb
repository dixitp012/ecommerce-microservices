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
  let(:rabbitmq_service) { instance_double("RabbitmqService", close: true) }
  let(:stock_check_service) { instance_double("StockCheckService", check_stock: true) }

  before do
    allow(RabbitmqService).to receive(:new).and_return(rabbitmq_service)
    allow(StockCheckService).to receive(:new).and_return(stock_check_service)
    allow(rabbitmq_service).to receive(:publish_event)

    stub_request(:get, "#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token")
      .with(headers: { 'Authorization' => 'Bearer valid_token' })
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token")
      .with(headers: { 'Authorization' => 'Bearer invalid_token' })
      .to_return(status: 401, body: '{"error":"Unauthorized"}', headers: {})
  end

  after do
    @rabbitmq_service&.close
  end

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

        it 'publishes an order.created event' do
          expect(rabbitmq_service).to have_received(:publish_event).with("order.created", anything)
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

      context 'when stock is insufficient' do
        before do
          allow(stock_check_service).to receive(:check_stock).and_return(false)
          post '/api/v1/orders', params: valid_attributes, headers: headers
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns an insufficient stock message' do
          expect(response.body).to match(/Insufficient stock for one or more products/)
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

  describe 'PUT /api/v1/orders/:id/cancel' do
    context 'with valid token' do
      context 'when the order exists' do
        before { put "/api/v1/orders/#{order_id}/cancel", headers: headers }

        it 'cancels the order' do
          expect(json['status']).to eq('canceled')
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'publishes an order.canceled event' do
          expect(rabbitmq_service).to have_received(:publish_event).with("order.canceled", anything)
        end
      end

      context 'when the order does not exist' do
        let(:order_id) { SecureRandom.uuid }

        before { put "/api/v1/orders/#{order_id}/cancel", headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Order/)
        end
      end
    end

    context 'with invalid token' do
      before { put "/api/v1/orders/#{order_id}/cancel", headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end
end
