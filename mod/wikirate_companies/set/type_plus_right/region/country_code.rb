def ok_to_update?
  Card::Auth.always_ok?
end

event :validate_country_code, :validate,
      on: :save, changed: :content do
  country_code = Card.search left: { type: :region },
                             right: :country_code,
                             content: card.content
  errors.add :content, "Country Code already exists" if country_code.present?
end
