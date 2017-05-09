#!/usr/bin/env ruby

require File.expand_path("../../config/environment", __FILE__)

ZEROS = { K: 3, M: 6, B: 9, T: 12, P: 15 }

UPDATER_ID = Card["Philipp Kuehl"].id

def change_value_type wrong_name, opts={}
  correct_name = opts[:to]
  value_type_cards(wrong_name).each do |card|
    metric_card = card.left
    puts "changing #{metric_card.name} to '#{correct_name}'"
    if opts[:to].in? %w[Number Money]
      sanitize_number_values metric_card
      Card::Cache.reset_all
    end
    yield metric_card if block_given?

    card.update_attributes! content: "[[#{correct_name}]]"
  end
end

def value_type_cards wrong_name
  wql = { right: { codename: "value_type" }, content: "[[#{wrong_name}]]" }
  Card.search(wql)
end

def sanitize_number_values metric_card
  metric_card.all_answers.each do |a|
    next unless a.value =~ /[,$KMBTP]/
    vc = Card[a.answer_id].value_card
    old_content = vc.content
    new_content = correct_zeros old_content.tr(",", "").tr("$", "")
    puts "  changing #{old_content} to #{new_content}"
    vc.update_column :db_content, new_content
  end
end

def correct_zeros number
  number.gsub(/^0?(\d*)(?:\.(\d+))?\s*([KMBTP])/) do
    zeros = "0" * zero_cnt(Regexp.last_match(3), Regexp.last_match(2))
    "#{Regexp.last_match(1)}#{Regexp.last_match(2)}#{zeros}"
  end
end

def zero_cnt letter, comma_digits
  cnt = ZEROS[letter.to_sym]
  return cnt unless comma_digits
  cnt - comma_digits.length
end

def change_value_type_to_category wrong_name
  change_value_type wrong_name, to: "Category" do |metric_card|
    options = metric_card.distinct_values
    if options.size > 10
      puts "  too many options: #{options.join ','}"
      return change_value_type wrong_name, to: "Free Text"
    end
    puts "  with options #{options.join ','}"

    metric_card.value_options_card
               .update_attributes! content: options.to_pointer_content
    Card::Cache.reset_all
  end
end

Card::Auth.current_id = UPDATER_ID
change_value_type_to_category "String"
change_value_type_to_category "Boolean"
change_value_type "Real", to: "Number"
change_value_type "Monetary", to: "Money"
