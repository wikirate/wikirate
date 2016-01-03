event :create_missing_companies, after: :store, on: :save do
  companies = item_names
  companies.each do |company|
    if !Card.exists? company
      Card.create! type_id: Card::WikirateCompanyID, name: company
    end
  end
end
