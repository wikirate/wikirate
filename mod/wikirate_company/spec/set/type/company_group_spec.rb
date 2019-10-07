
RSpec.describe Card::Set::Type::CompanyGroup do
  def card_subject
    Card["Deadliest"]
  end

  check_html_views_for_errors
end
