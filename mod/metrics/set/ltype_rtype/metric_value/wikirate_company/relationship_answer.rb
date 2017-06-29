include_set Abstract::MetricChild, generation: 3
include_set Abstract::ValueToggle
include_set Abstract::ResearchedValueDetails
include_set Abstract::MetricAnswer

format :html do
  view :company_name do
    nest card.cardname.right, view: :thumbnail
  end

  view :inverse_company_name do
    nest card.company_card, view: :thumbnail
  end

  view :value do
    value
  end

  view :closed_value do
    output [row, empty_details_slot]
  end

  def value_field
    _render_value_link
  end

  def value_details
    _render_researched_value_details
  end
end
