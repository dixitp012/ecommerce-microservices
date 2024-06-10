# frozen_string_literal: true

class ProductUpdateJob
  include Sidekiq::Job

  def perform(message)
    data = JSON.parse(message)
    event_type = data["event"]
    event_data = data["data"]

    case event_type
    when "order.created"
      update_product_stock(event_data, :reserve)
    when "order.canceled"
      update_product_stock(event_data, :release)
    else
      puts "Unknown event type: #{event_type}"
    end
  end

  private
    def update_product_stock(order_data, action)
      order_data["line_items"].each do |line_item|
        product = Product.find(line_item["product_id"])
        case action
        when :reserve
          product.update(reserved: product.reserved + line_item["quantity"])
        when :release
          product.update(reserved: 0, stock: product.stock + product.reserved )
        end
      end
    end
end
