RSpec.describe Card::Set::Type::Project do
  def card_subject
    sample_project
  end

  check_views_for_errors views: views(:html).push(:tabs)
end
