FactoryBot.define do
  factory :line_item do
    order
    product_id { SecureRandom.uuid }
    quantity { 1 }
    price_cents { 1000 }
  end
end
