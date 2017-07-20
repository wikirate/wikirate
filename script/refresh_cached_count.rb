require File.expand_path("../../config/environment",  __FILE__)
require File.expand_path("../wikirate_import_shared", __FILE__)
require "optparse"

def find_left_right_cached_count left, right
  puts "find #{left} type #{right} cached_count"
  results =
    if right.end_with? "_type"
      find_ltype_rtype_cached_count left, right
    else
      left_type_id = Card[left.to_sym].id
      type_cards = Card.search type_id: left_type_id, return: :name
      type_cards.map do |tc|
        Card.fetch "#{tc}+#{right}", new: {}
      end
    end
  puts "#{results.size} results found."
  results
end

def find_ltype_rtype_cached_count left, right
  left_type_id = Card[left.to_sym].id
  wql = { left: { type_id: left_type_id } }
  new_right = right.gsub("_type", "")
  wql[:right] =
    { type_id: Card[new_right.to_sym].id }
  Card.search wql
end

def check_option
  if ARGV.empty?
    msg =
      %(Please specify what cache should be refreshed.
options:
all\nmetric+wikirate_company_type\nmetric+value\nmetric+source
wikirate_company+metric\nwikirate_company+topic
wikirate_company+source\nwikirate_company+note
wikirate_topic+note\nwikirate_topic+metric
wikirate_topic+source\nwikirate_topic+company\n
wikirate_analysis+metric\nwikirate_analysis+source\n
wikirate_analysis+note)
    puts msg
    exit
  end
end

def refresh_all
  results = []
  %w[wikirate_company_type value source].each do |r|
    results += find_left_right_cached_count "metric", r
  end
  %w[metric topic source note].each do |r|
    results += find_left_right_cached_count "wikirate_company", r
  end
  %w[metric company source note].each do |r|
    results += find_left_right_cached_count "wikirate_topic", r
  end
  results
end

silent_mode do
  check_option
  cards =
    if ARGV[0] == "all"
      refresh_all
    else
      left_right = ARGV[0].split("+")
      find_left_right_cached_count left_right[0], left_right[1]
    end
  cards.each do |card|
    puts "Refreshing #{card.name}'s cached count".green
    card.update_cached_count
  end
end
