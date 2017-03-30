require File.expand_path("../../config/environment", __FILE__)

weird_company_wql = {
  "not" => { "type" => "Company" },
  "left_plus" => [
    { "type" => "Metric" },
    { "right_plus" => [{ "type" => "Year" }, { "type" => "Metric Value" }] }
  ]
}
Card::Auth.as_bot
weird_companies = Card.search weird_company_wql
weird_companies.each do |company|
  related_cards_wql = { left: { left: { type_id: Card::MetricID },
                                right: company.name } }
  related_cards = Card.search related_cards_wql
  related_cards.each do |related_card|
    if (value_card = Card[related_card.name + "+value"])
      puts "deleting #{value_card.name}".yellow
      value_card.delete!
    end
    if (source_card = Card[related_card.name + "+source"])
      puts "deleting #{source_card.name}".yellow
      source_card.delete!
    end
    puts "deleting #{related_card.name}".yellow
    related_card.delete!
  end
  puts "deleting #{company.name}".yellow
  company.delete! if company.type_id == Card::BasicID
end
