RSpec.describe Card::Set::Type::ResearchGroup do
  def card_subject
    Card["Jedi"]
  end

  check_views_for_errors :open_content, :listing, :edit,
                         :researcher_tab, :metric_tab, :project_tab
end
