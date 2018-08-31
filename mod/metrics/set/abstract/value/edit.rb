def unknown_subfield
  subfield :unknown
end

def attach_unknown
  attach_subfield :unknown, content: (unknown_value? ? "1" : "0")
end

format :html do
  # When editing +value cards, whether independently or within a form,
  # there is an "unknown" field, which is implemented as a card but never stored.

  # The check request card, which is a field of the answer, is also connected
  # to the value form.  (Note: it should probably either be moved to a field
  # of the value or moved out of the +value form.

  def edit_fields
    [
      value_field_card_and_options,
      unknown_field_card_and_options,
      check_request_field_card_and_options
    ]
  end

  # prevents multi-edit recursion on value field
  def edit_fields?
    voo.editor != :standard
  end

  def value_field_card_and_options
    [card, { title: "Answer", editor: :standard, hide: :help }]
  end

  def unknown_field_card_and_options
    [card.attach_unknown, { hide: [:title, :help] }]
  end

  def check_request_field_card_and_options
    [card.left(new: {}).fetch(trait: :checked_by, new: {}), { hide: :title }]
  end

  def metric_name_from_params
    Env.params[:metric]
  end

  def metric_card
    @metric_card = (metric_name = metric_name_from_params || card.metric) &&
                   Card[metric_name]
  end
end
