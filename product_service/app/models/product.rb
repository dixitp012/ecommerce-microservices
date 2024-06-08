# frozen_string_literal: true

class Product < ApplicationRecord
  monetize :price_cents, with_model_currency: :currency, as: :price

  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Enable optimistic locking
  self.locking_column = :lock_version

  def available_stock
    stock - reserved
  end
end
