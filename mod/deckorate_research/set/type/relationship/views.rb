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

format :json do
  def lookup
    @lookup ||= card.lookup
  end

  def atom
    fields =
      %i[year value metric_id inverse_metric_id subject_company_id object_company_id]

    super().merge(lookup_fields(fields)).merge(
      import: lookup.imported,
      comments: field_nest(:discussion, view: :core),
      subject_company: lookup.subject_company_id.cardname,
      object_company: lookup.object_company_id.cardname
    )
  end

  def lookup_fields fields
    fields.each_with_object({}) do |field, hash|
      hash[field] = lookup.send field
    end
  end

  def molecule
    super().merge subject_company: nest(card.company, view: :atom),
                  object_company: nest(card.related_company, view: :atom),
                  sources: field_nest(:source, view: :items),
                  checked_by: field_nest(:checked_by)
  end
end
