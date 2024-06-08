MoneyRails.configure do |config|
    # Set default currency
    config.default_currency = :usd
    
    Money.locale_backend = nil
    Money.rounding_mode = BigDecimal::ROUND_HALF_UP
end