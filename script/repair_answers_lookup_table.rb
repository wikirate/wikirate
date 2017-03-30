#!/usr/bin/env ruby

require File.expand_path("../../config/environment", __FILE__)

puts "metric: answer lookup table count/answer db count"
Card.search(type_id: Card::MetricID, return: :id).each do |m_id|
  db_ids = Card.search type_id: Card::MetricValueID,
                       left: { left_id: m_id },
                       return: :id
  cached_ids = Answer.where(metric_id: m_id).pluck :answer_id

  # assuming that if the count is correct the ids are correct
  next if db_ids.size == cached_ids.size

  puts "#{Card.fetch_name m_id}: #{cached_ids.size}/#{db_ids.size} updating ..."
  outdated_ids = (::Set.new(db_ids) ^ ::Set.new(cached_ids)).to_a
  Answer.refresh outdated_ids
end
