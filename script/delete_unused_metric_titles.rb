require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Card.search type: "Metric Title", not: { left_plus: [{}, { type: "Metric" }] } do |title|
  title_card = Card[title]

  if title_card.children.present?
    puts "title card still has children: #{title_card.children.map(&:name) * ', *'}"
  else
    title_card.delete!
  end
end
