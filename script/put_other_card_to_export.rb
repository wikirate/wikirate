#!/usr/bin/env ruby
require File.expand_path("../../config/environment",  __FILE__)
require "byebug"
Card::Auth.as_bot

def get_cards_included name, result
  unless result.include? name
    wql = { included_by: name }
    cards = Card.search wql
    cards.each do |c|
      get_cards_included c.name, result
    end
    puts "child added:#{name}"
    result.push name
  end

  result
end

card = Card["*read"]
klasses = Card.set_patterns.reverse.map do |set_class|
  next unless set_class != Card::Set::Type
  wql = { left: { type: Card::SetID },
          right: card.id,
          #:sort  => 'content',

          sort: %w[content name],
          limit: 0 }
  wql[:left][(set_class.anchorless? ? :id : :right_id)] = set_class.pattern_id

  rules = Card.search wql
  [set_class, rules] unless rules.empty?
end.compact
export_card = Card["export"]
export_card.item_cards.each do |c|
  export_card.drop_item c.name
end
export_card.save!
cards_in_export = []
klasses.map do |klass, rules|
  next if klass.anchorless?
  previous_content = nil
  rules.map do |rule|
    puts "#{klass}:#{rule.name}(#{rule.item_names} #{Card[rule.left.left.type_id].codename})" unless rule.item_names.include? "Anyone"
    next if rule.name.include? "*email+*right"
    next if rule.item_names.include? "Anyone"
    get_cards_included rule.left.left.name, cards_in_export
    cards_in_export.each do |cc|
      _card = Card[cc]
      puts "card type = #{_card.name} #{_card.type_id}"
      export_card.add_item cc if _card.type_id == 19
    end
  end
end
export_card.save!
