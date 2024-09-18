include_set Type::SearchType
include_set Abstract::ProjectList
include_set Abstract::CompanySearch

def cql_content
  {
    type: :company,
    referred_to_by: dataset_name&.field(:company)
  }
end

def skip_search?
  dataset_name.nil?
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
    voo.items[:view] = :bar if card.researchable_metrics?
  end

  def search_params
    super.merge append: card.project_name
  end

  def default_item_view
    :mini_bar
  end

  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end
end
