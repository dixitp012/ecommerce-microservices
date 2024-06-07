require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:product)).to be_valid
  end

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
end
