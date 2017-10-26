include_set Abstract::FilterFormgroups
include_set Abstract::FilterHelper
include_set Abstract::Utility

def advanced_filter_keys
  []
end

def filter_keys_with_values
  (filter_keys + advanced_filter_keys).map do |key|
    values = filter_param(key)
    next unless values.present?
    [key, values]
  end.compact
end

def all_filter_keys
  filter_keys + advanced_filter_keys
end

# def search_wql type_id, opts, params_keys, return_param=nil, &block
#   wql = { type_id: type_id }
#   wql[:return] = return_param if return_param
#   Filter.new(filter_keys_with_values, Env.params[:sort], wql, &wql).to_wql
# end

format :html do
  def sort_options
    { "Alphabetical" => "name" }
  end

  def filter_fields
    categories = card.filter_keys + card.advanced_filter_keys
    cats = categories.each_with_object({}) do |cat, h|
      h[cat] = { label: filter_label(cat),
                 input_field: _render("#{cat}_formgroup"),
                 active: show_filter_field?(cat) }
    end
    filter_form cats, action: filter_action_path,
                      class: "filter-container slotter sub-content",
                      id: "_filter_container"
  end

  delegate :filter_keys, to: :card
  delegate :advanced_filter_keys, to: :card

  def show_filter_field? field
    filter_param field
  end

  def filter_active?
    filter_keys.any? { |key| filter_param(key).present? }
  end
end
