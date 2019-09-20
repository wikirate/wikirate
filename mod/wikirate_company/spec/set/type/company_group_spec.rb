
RSpec.describe Card::Set::Type::CompanyGroup do
  def card_subject
    Card.create! name: "Soup Group",
                 type_code: :company_group
  end

  check_html_views_for_errors
end
