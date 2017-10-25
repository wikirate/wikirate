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

# def search_wql type_id, opts, params_keys, return_param=nil, &block
#   wql = { type_id: type_id }
#   wql[:return] = return_param if return_param
#   Filter.new(filter_keys_with_values, Env.params[:sort], wql, &wql).to_wql
# end

format :html do
  def main_filter_formgroups
    filter_fields filter_keys
  end

  def advanced_filter_formgroups
    return "".html_safe unless advanced_filter_keys
    filter_fields advanced_filter_keys
  end

  def sort_options
    { "Alphabetical" => "name" }
  end

  def filter_fields categories
    return "".html_safe unless categories.present?
    categories.map do |cat|
      _render "#{cat}_formgroup"
    end.join.html_safe
  end

  delegate :filter_keys, to: :card
  delegate :advanced_filter_keys, to: :card

  def filter_active? field=nil
    if field
      filter_keys.any? { |key| filter_param(key).present? }
    else
      filter_param(field).present?
    end
  end

  def filter_advanced_active?
    advanced_filter_keys.any? { |key| filter_param(key).present? }
  end

  def filter_title
    "Filter & Sort"
  end
end
