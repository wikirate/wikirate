include_set Abstract::Pointer

format :html do
  def editor
    options_count > 10 ? :select : :radio
  end

  private

  def options_count
    card.option_names.size
  end

  def option_names
    # value options
    option_card = Card.fetch "#{metric}+value options", new: {}
    option_card.item_names context: :raw
  end
end
