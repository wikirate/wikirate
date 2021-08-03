event :validate_applicable_year, :validate, on: :save, changed: :name do
  inapplicable year, metric_card.year_card&.item_names do
    errors.add :name, "Inapplicable Year: #{year}"
  end
end

event :validate_applicable_company, :validate, on: :save, changed: :name do
  inapplicable company_id, metric_card.company_group_card&.company_ids do
    errors.add :name, "Inapplicable Company: #{company}"
  end
end

def inapplicable val, restriction
  yield unless restriction.blank? || val.in?(restriction)
end
