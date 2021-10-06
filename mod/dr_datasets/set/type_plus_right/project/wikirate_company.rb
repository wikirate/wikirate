include_set Type::SearchType
include_set Right::BrowseCompanyFilter
include_set Abstract::ProjectList

def cql_content
  {
    type: :wikirate_company,
    referred_to_by: dataset_name.field(:wikirate_company),
    append: project_name
  }
end

# are any of the metrics associated with this dataset researchable for this user?
# @return [True/False]
def researchable_metrics?
  return false unless (metric_card = Card.fetch([dataset_name, :metric]))

  metric_card.item_cards.find(&:user_can_answer?)
end

format do
  def default_sort_option
    "name"
  end
end

format :html do
  before :core do
    voo.items[:show] = :bar_middle if card.researchable_metrics?
  end

  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end

  def export_formats
    []
  end
end
