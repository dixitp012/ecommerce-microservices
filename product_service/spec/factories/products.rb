FactoryBot.define do
	factory :product do
	  names = ["Laptop", "Smartphone", "Tablet", "Headphones", "Camera", "Smartwatch", "Printer", "Monitor", "Keyboard", "Mouse"]
	  descriptions = [
		"High-performance laptop with 16GB RAM and 512GB SSD.",
		"Latest smartphone with advanced camera features.",
		"Portable tablet with 10.5-inch display and 64GB storage.",
		"Noise-canceling headphones with superior sound quality.",
		"Digital camera with 20MP resolution and 4K video recording.",
		"Smartwatch with health monitoring and GPS tracking.",
		"All-in-one printer with wireless connectivity.",
		"27-inch monitor with 4K resolution and HDR support.",
		"Mechanical keyboard with RGB backlighting.",
		"Wireless mouse with ergonomic design and long battery life."
	  ]
  
	  name { names.sample }
	  description { descriptions.sample }
	  price_cents { rand(1000..10000) }  # Random price between 10.00 and 100.00 USD
	  price_currency { "USD" }
	  active { true }
	  stock { 100 }  # Random stock between 0 and 100
	  reserved { 0 }  # Random reserved stock between 0 and 20
	end
end
  
