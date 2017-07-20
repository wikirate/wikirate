#!/usr/bin/env ruby
require File.expand_path("../../config/environment",  __FILE__)
Card::Auth.as_bot

card = Card["*read"]
klasses = Card.set_patterns.reverse.map do |set_class|
  wql = { left: { type: Card::SetID },
          right: card.id,
          #:sort  => 'content',

          sort: %w[content name],
          limit: 0 }
  wql[:left][(set_class.anchorless? ? :id : :right_id)] = set_class.pattern_id

  rules = Card.search wql
  [set_class, rules] unless rules.empty?
end.compact

klasses.map do |klass, rules|
  next if klass.anchorless?
  previous_content = nil
  rules.map do |rule|
    current_content = rule.content.strip
    duplicate = previous_content == current_content
    changeover = previous_content && !duplicate
    previous_content = current_content

    puts "#{klass}:#{rule.name}(#{rule.item_names} #{Card[rule.left.left.type_id].codename})" unless rule.item_names.include? "Anyone"
    next if rule.name.include? "*email+*right"
    if rule.left.left.type_id == 5

      wql = { type: rule.left.left.name }
      children = Card.search wql
      children.each do |child|
        puts "Card: #{child.name} is deleted."
        child.delete!
      end
      puts "Cardtype: #{rule.left.left.name} is deleted."
      rule.left.left.delete!

    else
      unless rule.item_names.include? "Anyone"
        puts "#{rule.left.left.name} with permission only for #{rule.item_names} is deleted."
        Card[rule.left.left.name].delete!

      end
    end
  end
end
