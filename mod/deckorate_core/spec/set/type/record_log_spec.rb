RSpec.describe Card::Set::Type::RecordLog do
  def card_subject
    sample_record.left
  end

  check_views_for_errors views: (views(:html).unshift(:tabs) - [:record_phase])
  check_views_for_errors format: :csv
  check_views_for_errors format: :json, views: :molecule
end
