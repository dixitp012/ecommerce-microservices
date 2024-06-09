# frozen_string_literal: true

class Order < ApplicationRecord
  monetize :total_cents, with_model_currency: :currency, as: :total

  has_many :line_items, dependent: :destroy

  validates :user_id, presence: true
  validates :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :line_items, allow_destroy: true

  # Method to calculate total cost
  def calculate_total_cost
    self.total = line_items.sum { |item| item.price * item.quantity }
    save
  end
end
