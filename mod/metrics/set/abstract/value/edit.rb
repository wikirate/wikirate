include_set Abstract::Pointer

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
    voo.editor ||= :nests
    super()
  end

  view :editor do
    if free_text_metric?
      text_field :content, class: "d0-card-content"
    elsif categorical_metric? || multi_categorical_metric?
      super()
    else
      editor_with_unit
    end
  end

  def editor
    if multi_select?
      options_count > 10 ? :multiselect : :checkbox
    else
      options_count > 10 ? :select : :radio
    end
  end

  def edit_fields
    return if voo.editor == :standard
    [
      [card, { title: "Answer", editor: :standard, hide: :help }],
      [unknown_field_card, { hide: [:title, :help] }],
      [card.left(new: {}).fetch(trait: :checked_by, new: {}), { hide: :title }]
    ]
  end

  def editor_with_unit
    unit_text = wrap_with :span, nest(card.metric_card, view: :legend),
                          class: "metric-unit"
    text_field(:content, class: "d0-card-content short-input") + " " + unit_text
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
    metric_card&.value_type == "Free Text"
  end

  def multi_select?
    multi_categorical_metric?
  end

  def options_count
    card.option_names.size
  end

  def categorical_metric?
    metric_card&.categorical?
  end

  def multi_categorical_metric?
    metric_card&.multi_categorical?
  end
end
