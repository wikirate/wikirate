#!/usr/bin/env ruby

require File.expand_path("../../config/environment", __FILE__)

load File.expand_path("../correct_value_types.rb", __FILE__)

Card.search(type_id: Card::MetricID, return: :id).each do |metric_id|
  Card.search(type_id: Card::MetricValueID,
              left: { left_id: metric_id }).each do |card|
    Answer.create_or_update card
  end
end
