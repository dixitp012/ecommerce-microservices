class LineItem < ApplicationRecord
  monetize :price_cents, with_model_currency: :currency, as: :price
  
  belongs_to :order

  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

