def oc_code
  content.to_sym
end

event :clear_jurisdiction_key_cache do
  Card::Region.cache.reset_all
end

event :validate_jurisdiction_key, :validate, on: :save,
      changed: :content do
  oc_key = Card.search left: {type: :region},
                       right: :oc_jurisdiction_key,
                       content: card.content
  if oc_key.present?
    errors.add :content, "OC key already exists"
  end
end
