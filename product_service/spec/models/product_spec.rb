require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:product)).to be_valid
  end

  context 'validations' do
    it 'is invalid without a name' do
      product = FactoryBot.build(:product, name: nil)
      product.valid?
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a negative price' do
      product = FactoryBot.build(:product, price: -100)
      product.valid?
      expect(product.errors[:price_cents]).to include('must be greater than or equal to 0')
    end

    it 'is invalid without stock' do
      product = FactoryBot.build(:product, stock: nil)
      product.valid?
      expect(product.errors[:stock]).to include("can't be blank")
    end

    it 'is invalid with negative stock' do
      product = FactoryBot.build(:product, stock: -1)
      product.valid?
      expect(product.errors[:stock]).to include('must be greater than or equal to 0')
    end

    it 'is invalid without reserved quantity' do
      product = FactoryBot.build(:product, reserved: nil)
      product.valid?
      expect(product.errors[:reserved]).to include("can't be blank")
    end

    it 'is invalid with negative reserved quantity' do
      product = FactoryBot.build(:product, reserved: -1)
      product.valid?
      expect(product.errors[:reserved]).to include('must be greater than or equal to 0')
    end
  end

  context 'methods' do
    describe '#available_stock' do
      it 'returns the correct available stock' do
        product = FactoryBot.build(:product, stock: 10, reserved: 3)
        expect(product.available_stock).to eq(7)
      end
    end
  end
end
