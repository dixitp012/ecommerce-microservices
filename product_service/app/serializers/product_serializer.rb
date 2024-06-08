# frozen_string_literal: true

class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :currency, :active, :stock, :reserve, :created_at, :updated_at

  def price
    object.price.format
  end
end
