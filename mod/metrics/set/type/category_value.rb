include_set Abstract::Pointer

def option_card
  Card.fetch metric, :value_options, new: {}
end

def option_names
  option_card.item_names context: :raw
end

format :html do
  def editor
    options_count > 10 ? :select : :radio
  end

  private

  def options_count
    card.option_names.size
  end
end
