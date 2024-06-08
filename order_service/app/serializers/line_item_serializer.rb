class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :product_id, :quantity, :price, :order_id, :created_at, :updated_at
  
  belongs_to :order

  def price
    object.price.format
  end
end
