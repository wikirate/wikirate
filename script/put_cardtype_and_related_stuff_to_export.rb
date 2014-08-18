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
  if set_class==Card::TypeSet
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
      current_content = rule.content.strip
      duplicate = previous_content == current_content
      changeover = previous_content && !duplicate
      previous_content = current_content

      puts "#{klass}:#{rule.name}(#{rule.item_names} #{Card[rule.left.left.type_id].codename})" if !rule.item_names.include? "Anyone"
      if !rule.name.include? "*email+*right"
        if !rule.item_names.include? "Anyone"
          if klass==Card::TypeSet
            #get all related card and put them into export
            wql = { :type=> rule.left.left.name}

            cards_in_type = Card.search wql
            #byebug
            cards_in_type.each do |card|
              cards_in_export.push card.name
              puts "card added:#{card.name}"
            end

            wql = { :left=> {:type=> rule.left.left.name}}
            #byebug
            #cards in this type 
            related_cards = Card.search wql
           
            related_cards.each do |child|
              get_cards_included child.name,cards_in_export
              #cards_in_export.push child.name
              #cards_in_export.push child.name
              
            end

            export_card.add_item rule.left.left.name

            wql = { :left=> {:name=> rule.left.left.name}}
            left_part_of_card = Card.search wql
            left_part_of_card.each do |card|
              wql = { :left=> {:part=> rule.left.left.name},:right=>"*structure"}
              simple_structure = Card.search wql
              simple_structure.each do |str|
                export_card.add_item "#{str.name}"    
              end
              wql = { :left=> {:part=> rule.left.left.name},:right_plus=>"*structure"}
              right_plus_structure = Card.search wql
              right_plus_structure.each do |str|
                export_card.add_item "#{str.name}+*structure"    
              end
              #export_card.add_item "#{card.name}+*structure"  

            end
            puts "#{rule.left.name} #{rule.left.left.name}"
            
          end
        end
       
      end
    end

  end
end




puts "cards_in_export.count=#{cards_in_export.count}"
cards_in_export.each do |name|
  puts "add to export = #{name}"
  export_card.add_item name
end
puts "count = #{export_card.item_names.count}"
export_card.save!