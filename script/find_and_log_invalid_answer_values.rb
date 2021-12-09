require_relative "../config/environment"

FILENAME = "/tmp/invalid_answer_values.csv".freeze
SITE = "https://wikirate.org".freeze
VALUE_TYPES = %i[multi_category]
METRIC_TYPES = %i[researched]
OFFSET = 0

Card::Auth.as_bot

def validity answer_id
  answer = answer_id.card
  return if answer.relationship? || answer.calculated?

  val = answer.value_card
  if !Answer.unknown?(val.content) && val.illegal_items.present?
    record_invalid answer_id, "INVALID", val.content
  end
    #  record_invalid val, "INVALID", val.content unless val.valid?
rescue StandardError => e
  record_invalid answer_id, "ERROR", e.message
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

  validity answer_id
  milestones index
end
