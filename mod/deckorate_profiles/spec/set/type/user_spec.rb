RSpec.describe Card::Set::Type::User do
  def card_subject
    Card["Joe Camel"]
  end

  check_views_for_errors
end
