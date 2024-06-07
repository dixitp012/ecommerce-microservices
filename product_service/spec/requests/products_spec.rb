require 'rails_helper'

RSpec.describe "Products", type: :request do
  let!(:products) { create_list(:product, 10) }
  let(:product_id) { products.first.id }
  let(:headers) { { "Content-Type" => "application/json" } }

  # Helper method to parse JSON response
  def json
    JSON.parse(response.body)
  end

  # Test suite for GET /api/v1/products
  describe 'GET /api/v1/products' do
    before { get '/api/v1/products', headers: headers }

    it 'returns products' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /api/v1/products/:id
  describe 'GET /api/v1/products/:id' do
    context 'when the record exists' do
      before { get "/api/v1/products/#{product_id}", headers: headers }

      it 'returns the product' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(product_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:product_id) { 100 }

      before { get "/api/v1/products/#{product_id}", headers: headers }

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
    let(:valid_attributes) { { name: 'Product 1', description: 'Product description', price: 1000, currency: 'USD', active: true }.to_json }

    context 'when the request is valid' do
      before { post '/api/v1/products', params: valid_attributes, headers: headers }

      it 'creates a product' do
        expect(json['name']).to eq('Product 1')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { name: '' }.to_json }
      before { post '/api/v1/products', params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['error']).to include("Name can't be blank")
      end
    end
  end

  # Test suite for PUT /api/v1/products/:id
  describe 'PUT /api/v1/products/:id' do
    let(:valid_attributes) { { name: 'Updated Product' }.to_json }

    context 'when the record exists' do
      before { put "/api/v1/products/#{product_id}", params: valid_attributes, headers: headers }

      it 'updates the record' do
        expect(json['name']).to eq('Updated Product')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
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

  # Test suite for DELETE /api/v1/products/:id
  describe 'DELETE /api/v1/products/:id' do
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
end
