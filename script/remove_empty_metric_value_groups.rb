#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
# Card::Auth.as_bot
Card::Auth.current_id = Card::WagnBotID

Card.search(type: "Metric") do |metric|
  puts "~~~\n\nworking on METRIC: #{metric.name}"

  value_groups = Card.search(
    left_id: metric.id,
    right: { type: "Company" },
    not: {
      right_plus: [
        { type: "Year" },
        { type: "Metric Value" }
      ]
    }
  )

  value_groups.each do |group_card|
    puts "deleting #{group_card.name}"
    group_card.descendants.each do |desc|
      desc.update_column :trash, true
    end
    group_card.update_column :trash, true
  rescue
    puts "FAILED TO DELETE: #{group_card.name}"
  end
  puts "empty trash"
  Card.empty_trash
end
