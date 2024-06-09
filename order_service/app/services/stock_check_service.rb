# frozen_string_literal: true

# app/services/stock_check_service.rb
class StockCheckService
  def initialize(product_id, quantity)
    @product_id = product_id
    @quantity = quantity
    @token = ENV["USER_AUTH_SERVICE_TOKEN"]
    @base_url = ENV["PRODUCT_SERVICE_URL"]
  end

  def check_stock
    response = HTTP.auth("Bearer #{@token}")
                  .get("/api/v1/products/#{@product_id}/stock")
    if response.success?
      response.parsed_response["stock"] >= @quantity
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Failed to check stock: #{e.message}"
    false
  end
end
