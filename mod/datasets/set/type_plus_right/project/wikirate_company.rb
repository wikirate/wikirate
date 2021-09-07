include_set Abstract::CqlSearch
include_set Right::BrowseCompanyFilter
include_set Abstract::DatasetFilteredList

delegate :dataset_name, to: :project_card

def project_name
  name.left_name
end

def project_card
  left
end

def company_list
  dataset_name.field :wikirate_company
end

def cql_content
  {
    type_id: Card::WikirateCompanyID,
    referred_to_by: company_list,
    append: project_name
  }
end

def short_scope_code
  :company
end

format do
  def default_sort_option
    "name"
  end
end

format :html do
  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end

  def export_formats
    []
  end
end
