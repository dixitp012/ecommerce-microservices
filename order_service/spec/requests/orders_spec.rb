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

  describe 'PUT /api/v1/orders/:id' do
    let(:valid_attributes) { { user_id: user_id, line_items_attributes: [{ product_id: product_id, quantity: 2, price_cents: 1000 }] }.to_json }

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

end
