
RSpec.describe Card::Set::Type::Program do
  def card_subject
    Card["Test Program"]
  end
  check_views_for_errors :open_content, :bar, :edit, :metric_tab, :project_tab
end
