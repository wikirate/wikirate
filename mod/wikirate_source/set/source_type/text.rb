card_accessor :text, type: :basic

format :html do
  view :original_link do
    link_to_card card.text_card, (voo.title || "Visit Text Source")
  end

  def icon
    "pencil"
  end
end
