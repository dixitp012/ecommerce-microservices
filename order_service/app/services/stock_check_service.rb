# frozen_string_literal: true

class StockCheckService
  def initialize(product_id, quantity)
    @product_id = product_id
    @quantity = quantity
    @token = ENV["USER_AUTH_SERVICE_TOKEN"]
    @base_url = ENV["PRODUCT_SERVICE_URL"]
  end

  def check_stock
    response = HTTP.auth("Bearer #{@token}")
                  .get("#{@base_url}/api/v1/products/#{@product_id}/available_stock")
    if response.status.success?
      response.parse["stock"] >= @quantity
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Failed to check stock: #{e.message}"
    false
  end
end
