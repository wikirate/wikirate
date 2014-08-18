#!/usr/bin/env ruby
require File.expand_path('../../config/environment',  __FILE__)
require 'byebug'
Card::Auth.as_bot


def get_cards_included name, result
  if !result.include? name
    wql = { :included_by=> name}
    cards = Card.search wql  
    cards.each do |c|
      get_cards_included c.name,result
    end
    puts "child added:#{name}"
    result.push name
  end

  return result
end

card = Card["*read"]
klasses = Card.set_patterns.reverse.map do |set_class|
  if set_class!=Card::TypeSet
    wql = { :left  => { :type =>Card::SetID },
    :right => card.id,
            #:sort  => 'content',
            
            :sort  => ['content', 'name'],
            :limit => 0
          }
    wql[:left][ (set_class.anchorless? ? :id : :right_id )] = set_class.pattern_id

    rules = Card.search wql
    [ set_class, rules ] unless rules.empty?
  end
end.compact
export_card = Card["export"]
export_card.item_cards.each do |c|
  export_card.drop_item c.name
end
export_card.save!
cards_in_export = Array.new
klasses.map do |klass, rules|

  unless klass.anchorless?
    previous_content = nil
    rules.map do |rule|
     
      # wql = { :included_by=> rule.left.left.name}
      # card_included = Card.search wql
      # #byebug
      # card_included.each do |card|
      #   export_card.add_item card.name
      #   puts "card added:#{card.name}"
      # end
      
      puts "#{klass}:#{rule.name}(#{rule.item_names} #{Card[rule.left.left.type_id].codename})" if !rule.item_names.include? "Anyone"
      if !rule.name.include? "*email+*right"
        if !rule.item_names.include? "Anyone"
          get_cards_included rule.left.left.name,cards_in_export
          cards_in_export.each do |cc|
            _card = Card[cc]
            puts "card type = #{_card.name} #{_card.type_id}"
            export_card.add_item cc if _card.type_id ==  19

          end
            #export_card.add_item rule.left.left.name
            #export_card.save!
          
        end
       
      end
    end

  end
end
puts "count=#{export_card.item_names.count}"
export_card.save!