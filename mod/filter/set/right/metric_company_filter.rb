include_set Abstract::RightFilterForm
include_set Abstract::FilterFormgroups
include_set Abstract::BookmarkFiltering

def filter_keys
  %i[status year company_name value updated company_group check source project outliers
     bookmark]
end

def default_filter_hash
  { year: :latest, status: :exists, company_name: "" }
end

def bookmark_type
  :wikirate_company
end

format :html do
  def metric_card
    @metric_card ||= card.left.metric_card
  end

  def quick_filter_list
    @quick_filter_list ||=
      Card.fetch(:wikirate_company, :browse_company_filter).format.quick_filter_list
  end

  view :filter_value_formgroup do
    filter_value_formgroup metric_card.simple_value_type_code
  end

  def filter_value_formgroup metric_type, default=nil
    send "#{value_filter_type metric_type}_filter", :value, default
  end

  def value_filter_type value_type
    case value_type
    when :category, :multi_category
      :multiselect
    when :number, :money
      :range
    else
      :text
    end
  end

  def value_options
    metric_card.value_options_card&.options_hash
  end
end

# no sort options because sorting is done by links
# in the header of the table
