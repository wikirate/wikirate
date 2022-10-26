RSpec.describe Card::Set::Type::Metric::Creation do
  def card_subject
    Card.new type: :metric
  end

  check_views_for_errors
end
