event :create_missing_companies, :integrate, on: :save do
  companies = item_names
  companies.each do |company|
    if !Card.exists? company
      add_subcard company, type_id: Card::WikirateCompanyID
    end
  end
end
