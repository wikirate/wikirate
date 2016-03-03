card_accessor :text, type: :basic

format :html do
  view :original_link do |args|
    card_link card.text_card, text: (args[:title] || 'Visit Text Source')
  end

  def icon
    'pencil'
  end
end
