FactoryBot.define do
	factory :product do
	  name { "Macbook Pro" }
	  description { "Test Description...." }
	  price_cents { 910000 }
	  price_currency { "USD" }
	  currency { "USD" }
	  active { false }
	  stock { 100 } # Add a default value for stock
	  reserved { 0 }
	end
  end
