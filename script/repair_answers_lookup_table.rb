#!/usr/bin/env ruby

require File.expand_path("../../config/environment", __FILE__)

puts "metric: record lookup table count/record db count"
Card.search(type_id: Card::MetricID, return: :id).each do |m_id|
  db_ids = Card.search type_id: Card::RecordID,
                       left: { left_id: m_id },
                       return: :id
  cached_ids = ::Record.where(metric_id: m_id).pluck :record_id

  # assuming that if the count is correct the ids are correct
  next if db_ids.size == cached_ids.size

  puts "#{m_id.cardname}: #{cached_ids.size}/#{db_ids.size} updating ..."
  outdated_ids = (::Set.new(db_ids) ^ ::Set.new(cached_ids)).to_a
  Record.refresh outdated_ids
end
