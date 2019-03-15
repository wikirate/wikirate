include_set Abstract::MetricChild, generation: 3
include_set Abstract::AnswerDetailsToggle
include_set Abstract::ExpandedResearchedDetails
include_set Abstract::MetricAnswer

format :html do
  view :company_name do
    nest card.name.right, view: :thumbnail
  end

  view :inverse_company_name do
    nest card.company_card, view: :thumbnail
  end

  view :value do
    value
  end

  view :basic_details do
    nest card.value_card, view: :pretty_link
  end

  view :expanded_details do
    _render :expanded_researched_details
  end

  def credit_details
    wrap_with :div, class: "d-flex" do
      [
        nest(card.value_card, view: :credit),
        link_to_card(card, menu_icon, path: { view: :edit }, class: "text-dark ml-auto")
      ]
    end
  end
end
