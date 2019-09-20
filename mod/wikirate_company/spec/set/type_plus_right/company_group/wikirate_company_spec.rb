
RSpec.describe Card::Set::TypePlusRight::CompanyGroup::WikirateCompany do
  def card_subject
    Card.create! name: "Soup Group",
                 type_code: :company_group,
                 "+specification": "woot"
  end
end
