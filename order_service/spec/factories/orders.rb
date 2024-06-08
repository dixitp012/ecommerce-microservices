FactoryBot.define do
  factory :order do
    user_id { SecureRandom.uuid }
    total_cents { 0 }
  end
end
