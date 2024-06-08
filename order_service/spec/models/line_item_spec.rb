require 'rails_helper'

RSpec.describe LineItem, type: :model do
  describe 'associations' do
    it 'belongs to order' do
      association = described_class.reflect_on_association(:order)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'money attributes' do
    it 'responds to price_cents' do
      line_item = LineItem.new
      expect(line_item).to respond_to(:price_cents)
      expect(line_item).to respond_to(:price)
    end

    it 'handles money properly' do
      line_item = LineItem.new(price_cents: 1000)
      expect(line_item.price).to eq(Money.new(1000))
    end
  end

  describe 'validations' do
    it 'validates presence of product_id' do
      line_item = LineItem.new(product_id: nil)
      expect(line_item).not_to be_valid
      expect(line_item.errors[:product_id]).to include("can't be blank")
    end

    it 'validates presence of quantity' do
      line_item = LineItem.new(quantity: nil)
      expect(line_item).not_to be_valid
      expect(line_item.errors[:quantity]).to include("can't be blank")
    end

    it 'validates numericality of quantity' do
      line_item = LineItem.new(quantity: -1)
      expect(line_item).not_to be_valid
      expect(line_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'validates presence of price_cents' do
      line_item = LineItem.new(price_cents: nil)
      expect(line_item).not_to be_valid
      expect(line_item.errors[:price_cents]).to include("can't be blank")
    end

    it 'validates numericality of price_cents' do
      line_item = LineItem.new(price_cents: -1)
      expect(line_item).not_to be_valid
      expect(line_item.errors[:price_cents]).to include("must be greater than or equal to 0")
    end
  end
end
