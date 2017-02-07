def option_names
  # value options
  option_card = Card.fetch "#{metric}+value options", new: {}
  option_card.item_names context: :raw
end

format :html do
  view :content_formgroup do
    voo.editor = :nests
    super()
  end

  view :edit_in_form, cache: :never, perms: :update, tags: :unknown_ok do
    @form_root = true
    voo.editor ||= :nests
    super()
  end

  view :editor do
    if free_text_metric? || categorical_metric?
      super()
    else
      editor_with_unit
    end
  end

  def edit_fields
    [
      [card, { title: "Answer", editor: :standard }],
      [unknown_field_card, { hide: :title }],
      [card.left.fetch(trait: :checked_by, new: {}), { hide: :title }]
    ]
  end

  def editor_with_unit
    text_field(:content, class: "card-content short-input") + " " +
      nest(card.metric_card, view: :legend)
  end

  def unknown_field_card
    field = card.attach_subfield :unknown
    field.content = card.value_unknown? ? "1" : "0"
    field
  end

  def check_request_checkbox
    nest card.left.fetch(trait: :checked_by),
         hide: :title, view: :edit_in_form
  end

  def metric_name_from_params
    Env.params[:metric]
  end

  def metric_card
    @metric_card = (metric_name = metric_name_from_params || card.metric) &&
      Card[metric_name]
  end

  def free_text_metric?
    metric_card && metric_card.value_type == "Free Text"
  end

  def categorical_metric?
    metric_card && metric_card.categorical?
  end
end
