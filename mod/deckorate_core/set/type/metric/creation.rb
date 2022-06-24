format :html do
  view :new do
    if card.field? :metric_type
      super()
    else
      haml :new_metric
    end
  end

  view :name_formgroup, cache: :never do
    return super() unless card.new?

    formgroup "Metric Name", input: "name", help: false do
      new_metric_name_field
    end
  end

  def new_metric_link metric_type
    nest metric_type, view: :box
  end

  def layout_for_view view
    :deckorate_layout if view&.to_sym.in? %i[new new_formula]
  end

  def new_view_hidden
    hidden_tags card: {
      fields: Card::Env.hash(params.dig(:card, :fields)),
      subcards: Card::Env.hash(params.dig(:card, :subcards))
    }
  end

  def new_metric_name_field
    bs_layout do
      row 5, 1, 6 do
        column { name_part_field :designer, Auth.current.name, title: "Metric Designer" }
        column { '<div class="plus">+</div>' }
        column { title_fields }
      end
    end
  end

  def title_fields
    name_part_field :title, card.name.right, title: "Metric Title"
  end

  def name_part_field field, content, options={}
    pseudo_card = card.field field, content: content, type: :phrase
    subformat(pseudo_card)._render_edit_in_form options
  end
end
