# event :create_missing_companies, :integrate, on: :save do
#   return unless type_id.in? [Card::PointerID, Card::ListID]
#   companies = item_names
#   companies.each do |company|
#     subcard company, type_id: Card::CompanyID unless Card.exists? company
#   end
# end
