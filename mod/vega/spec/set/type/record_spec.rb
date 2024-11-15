RSpec.describe Card::Set::Type::Record do
  def card_subject
    sample_record :category
  end

  check_views_for_errors format: :json, views: %i[record_list vega]
end
