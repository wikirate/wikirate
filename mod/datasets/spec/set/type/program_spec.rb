
RSpec.describe Card::Set::Type::Program do
  def card_subject
    Card["Test Program"]
  end
  check_html_views_for_errors
end
