FactoryBot.define do
	factory :product do
		name { Faker::Commerce.product_name }
		description { Faker::Lorem.paragraph }
		price { Faker::Commerce.price(range: 10..100, as_string: false) * 100 } # Price in cents
		currency { 'USD' }
		active { Faker::Boolean.boolean }
	end
end
