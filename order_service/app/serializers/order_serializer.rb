# frozen_string_literal: true

class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :total, :status, :created_at, :updated_at

  has_many :line_items

  def total
    object.total.format
  end
end
