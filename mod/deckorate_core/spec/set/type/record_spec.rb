RSpec.describe Card::Set::Type::Record do
  def card_subject
    sample_answer.left
  end

  check_views_for_errors views: (views(:html).unshift(:tabs) - [:answer_phase])
  check_views_for_errors format: :csv
  check_views_for_errors format: :json, views: :molecule
end
