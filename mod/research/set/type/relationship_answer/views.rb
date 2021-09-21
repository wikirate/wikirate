format do
  view :legend do
    subf = subformat card.metric_card
    subf.wrap_legend { subf.value_legend }
  end
end

format :html do
  # TODO: make relationship answer pages look more like answer pages and use two
  # column layout
  view :open_content do
    bs do
      layout do
        row 3, 9 do
          column render_basic_details
          column do
            row 12 do
              column _render_expanded_details
            end
          end
        end
      end
    end
  end

  view :bar_left do
    wrap_with :div, class: "d-block" do
      [company_thumbnail(card.company, hide: :thumbnail_subtitle),
       company_thumbnail(card.related_company, hide: :thumbnail_subtitle),
       render_metric_thumbnail]
    end
  end

  view :core do
    render_expanded_details
  end

  view :content_formgroup do
    card.add_subfield :year, content: card.year
    card.add_subfield :related_company, content: card.related_company
    super()
  end

  view :company_name do
    nest card.name.right, view: :thumbnail
  end

  view :inverse_company_name do
    nest card.company_card, view: :thumbnail
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

  def default_research_params
    super.merge related_company: card.related_company
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
