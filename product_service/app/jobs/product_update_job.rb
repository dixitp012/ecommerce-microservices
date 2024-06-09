# frozen_string_literal: true

class ProductUpdateJob
  include Sidekiq::Job

  def perform(message)
    data = JSON.parse(message)
    event_type = data["event"]
    event_data = data["data"]

    case event_type
    when "order.created"
      update_product_stock(event_data)
    else
      puts "Unknown event type: #{event_type}"
    end
  end

  private
    def update_product_stock(order_data)
      order_data["line_items"].each do |line_item|
        product = Product.find(line_item["product_id"])
        product.update(reserved: product.reserved + line_item["quantity"])
      end
    end
end
