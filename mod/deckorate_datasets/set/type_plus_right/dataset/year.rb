include_set Abstract::Table
include_set Abstract::ListCachedCount
include_set Abstract::DatasetScope

def hereditary_field?
  false
end

format :html do
  def input_type
    :multiselect
  end

  # view :core do
  #   filtering(".RIGHT-answer ._compact-filter") do
  #     wrap_with :div, class: "pointer-list" do
  #       filterable_years
  #     end
  #   end
  # end
  #
  # def filterable_years
  #   card.item_names.map do |year|
  #     filterable({ year: year }, class: "pointer-item item-name") { year }
  #   end.join ", "
  # end
end
