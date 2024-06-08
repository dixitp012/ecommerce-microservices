require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it 'has many line items' do
      association = described_class.reflect_on_association(:line_items)
      expect(association.macro).to eq :has_many
    end

    it 'destroys dependent line items' do
      order = create(:order)
      line_item = create(:line_item, order: order)
      expect { order.destroy }.to change { LineItem.count }.by(-1)
    end
  end

  describe 'money attributes' do
    it 'responds to total_cents' do
      order = Order.new
      expect(order).to respond_to(:total_cents)
      expect(order).to respond_to(:total)
    end

    it 'handles money properly' do
      order = Order.new(total_cents: 1000)
      expect(order.total).to eq(Money.new(1000))
    end
  end

  describe 'validations' do
    it 'validates presence of user_id' do
      order = Order.new(user_id: nil)
      expect(order).not_to be_valid
      expect(order.errors[:user_id]).to include("can't be blank")
    end

    it 'validates presence of total_cents' do
      order = Order.new(total_cents: nil)
      expect(order).not_to be_valid
      expect(order.errors[:total_cents]).to include("can't be blank")
    end

    it 'validates numericality of total_cents' do
      order = Order.new(total_cents: -1)
      expect(order).not_to be_valid
      expect(order.errors[:total_cents]).to include("must be greater than or equal to 0")
    end
  end

  describe '#calculate_total_cost' do
    let(:order) { create(:order) }
    let(:line_item1) { create(:line_item, order: order, price_cents: 1000, quantity: 2) }
    let(:line_item2) { create(:line_item, order: order, price_cents: 2000, quantity: 1) }

    it 'calculates the total cost of the order' do
      line_item1
      line_item2
      order.calculate_total_cost
      expect(order.total_cents).to eq(4000)
    end
  end
end
