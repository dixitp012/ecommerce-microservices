# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Products", type: :request do
  let!(:products) { create_list(:product, 10) }
  let(:product_id) { products.first.id }
  let(:headers) { { "Content-Type" => "application/json", "Authorization" => "Bearer valid_token" } }
  let(:invalid_headers) { { "Content-Type" => "application/json", "Authorization" => "Bearer invalid_token" } }

  before do
    stub_request(:get, "#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token")
      .with(headers: { 'Authorization' => 'Bearer valid_token' })
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "#{ENV['USER_AUTH_SERVICE_URL']}/auth/validate_token")
      .with(headers: { 'Authorization' => 'Bearer invalid_token' })
      .to_return(status: 401, body: "", headers: {})
  end

  # Test suite for GET /api/v1/products
  describe 'GET /api/v1/products' do
    context 'without authentication' do
      before { get '/api/v1/products' }

      it 'returns products' do
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /api/v1/products/:id
  describe 'GET /api/v1/products/:id' do
    context 'without authentication' do
      context 'when the record exists' do
        before { get "/api/v1/products/#{product_id}" }

        it 'returns the product' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(product_id)
          expect(json['stock']).to eq(products.first.stock)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        let(:product_id) { 100 }

        before { get "/api/v1/products/#{product_id}" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Product/)
        end
      end
    end
  end

  # Test suite for GET /api/v1/products/:id/available_stock
  describe 'GET /api/v1/products/:id/available_stock' do
    context 'with valid token' do
      before { get "/api/v1/products/#{product_id}/available_stock", headers: headers }

      it 'returns the stock of the product' do
        expect(json).not_to be_empty
        expect(json['stock']).to eq(products.first.stock)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid token' do
      before { get "/api/v1/products/#{product_id}/available_stock", headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end

    context 'when the record does not exist' do
      let(:product_id) { 100 }

      before { get "/api/v1/products/#{product_id}/available_stock", headers: headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Product/)
      end
    end
  end

  # Test suite for POST /api/v1/products
  describe 'POST /api/v1/products' do
    let(:valid_attributes) { { name: 'Product 1', description: 'Product description', price: 1000, currency: 'USD', stock: 10, active: true }.to_json }

    context 'with valid token' do
      context 'when the request is valid' do
        before { post '/api/v1/products', params: valid_attributes, headers: headers }

        it 'creates a product' do
          expect(json['name']).to eq('Product 1')
          expect(json['stock']).to eq(10)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the request is invalid' do
        let(:invalid_attributes) { { name: '', stock: -5 }.to_json }
        before { post '/api/v1/products', params: invalid_attributes, headers: headers }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(json['error']).to include("Name can't be blank", "Stock must be greater than or equal to 0")
        end
      end
    end

    context 'with invalid token' do
      before { post '/api/v1/products', params: valid_attributes, headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for PUT /api/v1/products/:id
  describe 'PUT /api/v1/products/:id' do
    let(:valid_attributes) { { name: 'Updated Product', stock: 15 }.to_json }

    context 'with valid token' do
      context 'when the record exists' do
        before do
          allow(Product).to receive(:lock).and_call_original
          put "/api/v1/products/#{product_id}", params: valid_attributes, headers: headers
        end

        it 'updates the record' do
          expect(json['name']).to eq('Updated Product')
          expect(json['stock']).to eq(15)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when a concurrent edit occurs' do
        it 'retries the update up to 3 times' do
          attempt_count = 0
          allow(Product).to receive(:lock) do
            attempt_count += 1
            raise ActiveRecord::StaleObjectError.new(Product.new, 'update') if attempt_count < 4
            products.first
          end

          put "/api/v1/products/#{product_id}", params: valid_attributes, headers: headers
          expect(Product).to have_received(:lock).exactly(3).times
          expect(response).to have_http_status(:conflict)
          expect(json['error']).to eq('Product update failed due to a concurrent edit. Please try again.')
        end
      end

      context 'when the record does not exist' do
        let(:product_id) { 100 }

        before { put "/api/v1/products/#{product_id}", params: valid_attributes, headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Product/)
        end
      end
    end

    context 'with invalid token' do
      before { put "/api/v1/products/#{product_id}", params: valid_attributes, headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for DELETE /api/v1/products/:id
  describe 'DELETE /api/v1/products/:id' do
    context 'with valid token' do
      context 'when the record exists' do
        before { delete "/api/v1/products/#{product_id}", headers: headers }

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when the record does not exist' do
        let(:product_id) { 100 }

        before { delete "/api/v1/products/#{product_id}", headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Product/)
        end
      end
    end

    context 'with invalid token' do
      before { delete "/api/v1/products/#{product_id}", headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  # Test suite for POST /api/v1/products/:id/add_stock
  describe 'POST /api/v1/products/:id/add_stock' do
    let(:valid_attributes) { { stock: 5 }.to_json }

    context 'with valid token' do
      context 'when the request is valid' do
        before { post "/api/v1/products/#{product_id}/add_stock", params: valid_attributes, headers: headers }

        it 'adds stock to the product' do
          products.first.reload
          expect(json['stock']).to eq(products.first.stock)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the request is invalid' do
        let(:invalid_attributes) { { stock: -5 }.to_json }
        before { post "/api/v1/products/#{product_id}/add_stock", params: invalid_attributes, headers: headers }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(json['error']).to include("Stock must be greater than 0")
        end
      end

      context 'when the record does not exist' do
        let(:product_id) { 100 }
        before { post "/api/v1/products/#{product_id}/add_stock", params: valid_attributes, headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Product/)
        end
      end
    end

    context 'with invalid token' do
      before { post "/api/v1/products/#{product_id}/add_stock", params: valid_attributes, headers: invalid_headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end
end
