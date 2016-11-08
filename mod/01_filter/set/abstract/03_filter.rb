include_set Abstract::FilterFormgroups
include_set Abstract::FilterQuery

def advanced_filter_keys
  []
end

format :html do
  def view_caching?
    false
  end

  def main_filter_formgroups
    filter_fields filter_keys
  end

  def advanced_filter_formgroups
    return "".html_safe unless advanced_filter_keys
    filter_fields advanced_filter_keys
  end

  def page_link_params
    [:sort] + card.params_keys
  end

  def sort_options
      { "Alphabetical" => "name" }
  end

  def filter_fields categories
    return "".html_safe unless categories.present?
    categories.map do |cat|
      _optional_render "#{cat}_formgroup"
    end.join.html_safe
  end

  delegate :filter_keys, to: :card
  delegate :advanced_filter_keys, to: :card

  def filter_active?
    filter_keys.any? { |key| filter_param(key).present? }
  end

  def filter_advanced_active?
    advanced_filter_keys.any? { |key| filter_param(key).present? }
  end

  def filter_title
    "Filter & Sort"
  end
end
