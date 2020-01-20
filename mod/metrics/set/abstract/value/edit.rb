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
    ].compact
  end

  # prevents multi-edit recursion on value field
  def edit_fields?
    voo.input_type != :standard
  end

  def value_field_card_and_options
    val_card =
      if card.relationship? && card.new?
        # For adding new relationship answers.
        # The card is the (existing) metric answer card M+C+Y+values with
        # the company count.
        # With this change we get the right editor for creating a new relationship value.
        Card.new name: card.name, type_id: card.metric_card.value_cardtype_id
      else
        card
      end
    [val_card, { title: "Answer", input_type: :standard, show: :help }]
  end

  def unknown_field_card_and_options
    [card.attach_unknown, { hide: [:title, :help] }]
  end

  def check_request_field_card_and_options
    return if card.metric_card&.designer_assessed?
    [check_request_base.fetch(:checked_by, new: {}), { hide: :title }]
  end

  def check_request_base
    card.left new: {}
  end
end
