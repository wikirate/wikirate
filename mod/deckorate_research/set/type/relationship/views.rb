format do
  view :legend do
    subf = subformat card.metric_card
    subf.wrap_legend { subf.value_legend }
  end
end

format :html do
  def tab_list
    [:details]
  end

  view :details_tab do
    render_read_form
  end

  view :bar_left, template: :haml

  view :content_formgroup do
    card.field :year, content: card.year
    card.field :related_company, content: card.related_company
    super()
  end

  view :company_name do
    nest card.name.right, view: :thumbnail
  end

  view :inverse_company_name do
    nest card.company_card, view: :thumbnail
  end

  def credit_details
    wrap_with :div, class: "d-flex" do
      [
        nest(card.value_card, view: :credit),
        link_to_card(card, menu_icon, path: { view: :edit }, class: "text-dark ms-auto")
      ]
    end
  end

  def default_research_params
    super.merge related_company: card.related_company
  end

  def header_list_items
    super.merge(
      "Subject Company": link_to_card(card.company_card),
      "Object Company": link_to_card(card.related_company_card),
      "Year": card.year
    )
  end
end
