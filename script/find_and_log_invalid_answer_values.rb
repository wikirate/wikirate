# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../config/environment"

FILENAME = "/tmp/invalid_answer_values.csv".freeze
SITE = "https://wikirate.org".freeze
VALUE_TYPES = %i[multi_category].freeze
METRIC_TYPES = %i[researched].freeze
OFFSET = 0

Card::Auth.as_bot

def validate answer_id
  answer = answer_id.card
  return if answer.relationship? || answer.calculated?

  validate_value answer.value_card
rescue StandardError => e
  record_invalid answer_id, "ERROR", e.message
end

def validate_value val
  return if Answer.unknown?(val.content) || !val.illegal_items.present?

  record_invalid answer_id, "INVALID", val.content
end

def milestones seq
  puts "TRACK SEQ: #{seq}" if (seq % 1000).zero?
  Card::Cache.reset_soft
end

def record_invalid answer_id, type, msg
  url = "#{SITE}/~#{answer_id}"
  puts "#{type}: #{url}"
  File.open FILENAME, "a" do |file|
    file.puts "#{type},#{answer_id},#{url},#{msg}"
  end
end

Metric.joins("join answers on metrics.metric_id = answers.metric_id")
      .where(value_type_id: VALUE_TYPES.map(&:card_id),
             metric_type_id: METRIC_TYPES.map(&:card_id))
      .select(:answer_id).offset(OFFSET)
      .pluck(:answer_id).each_with_index do |answer_id, index|

  validate answer_id
  milestones index
end
