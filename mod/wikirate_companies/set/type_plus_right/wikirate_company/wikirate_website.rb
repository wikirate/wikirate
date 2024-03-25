event :validate_website, :validate, on: :save do
  unless content.match?(/\A#{URI.regexp %w[http https]}\z/)
    errors.add :content, "must be url (starting with http)"
  end
end
