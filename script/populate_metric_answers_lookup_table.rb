# -*- encoding : utf-8 -*-

require File.expand_path("../../config/environment",  __FILE__)

require 'pry'
Card.search(type_id: Card::MetricID, return: :id).each do |metric_id|

  Card.search(type_id: Card::MetricValueID,
              left: { left_id: metric_id }).each do |card|

    binding.pry if card.new_card?
    MetricAnswer.create_or_update card
  end
end
