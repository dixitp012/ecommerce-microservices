class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :total, :created_at, :updated_at
  
  has_many :line_items

  def total
    object.total.format
  end
end
