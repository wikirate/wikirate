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

  def default_research_params
    super.merge related_company: card.related_company
  end
end

format :json do
  def atom
    super().merge year: card.year.to_s,
                  value: card.value,
                  import: card.imported?,
                  comments: field_nest(:discussion, view: :core),
                  subject_company: Card.fetch_name(card.company),
                  object_company: Card.fetch_name(card.related_company)
  end

  def molecule
    super().merge subject_company: nest(card.company, view: :atom),
                  object_company: nest(card.related_company, view: :atom)
  end
end
