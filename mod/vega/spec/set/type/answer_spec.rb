RSpec.describe Card::Set::Type::Answer do
  def card_subject
    sample_answer :category
  end

  check_views_for_errors format: :json, views: %i[answer_list vega]
end
