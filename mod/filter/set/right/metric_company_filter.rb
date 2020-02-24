STANDARD_FILTER_KEYS = %i[status year company_name value updated check calculated
                          company_group source project outliers bookmark].freeze

include_set Abstract::RightFilterForm
include_set Abstract::FilterFormgroups
include_set Abstract::BookmarkFiltering

def filter_keys
  STANDARD_FILTER_KEYS + special_filter_keys
end

def special_filter_keys
  metric_card.relationship? ? [:related_company_group] : []
end

def default_filter_hash
  { year: :latest, status: :exists, company_name: "" }
end

def bookmark_type
  :wikirate_company
end

def metric_card
  @metric_card ||= left&.metric_card
end

format :html do
  delegate :metric_card, to: :card

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

  view :filter_related_company_group_formgroup, cache: :never do
    filter_related_company_group_formgroup
  end

  def filter_related_company_group_formgroup default=nil
    select_filter :related_company_group, default
  end

  def related_company_group_options
    type_options :company_group
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
