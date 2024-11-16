require_relative "../config/environment"

FILENAME = "/tmp/invalid_record_values.csv".freeze
SITE = "https://wikirate.org".freeze
VALUE_TYPES = %i[multi_category].freeze
METRIC_TYPES = %i[researched].freeze
OFFSET = 0

Card::Auth.as_bot

def validate record_id
  record = record_id.card
  return if record.relation? || record.calculated?

  validate_value record.value_card
rescue StandardError => e
  record_invalid record_id, "ERROR", e.message
end

def validate_value val
  return if Record.unknown?(val.content) || !val.illegal_items.present?

  record_invalid record_id, "INVALID", val.content
end

def milestones seq
  puts "TRACK SEQ: #{seq}" if (seq % 1000).zero?
  Card::Cache.reset_temp
end

def record_invalid record_id, type, msg
  url = "#{SITE}/~#{record_id}"
  puts "#{type}: #{url}"
  File.open FILENAME, "a" do |file|
    file.puts "#{type},#{record_id},#{url},#{msg}"
  end
end

Metric.joins("join records on metrics.metric_id = records.metric_id")
      .where(value_type_id: VALUE_TYPES.map(&:card_id),
             metric_type_id: METRIC_TYPES.map(&:card_id))
      .select(:record_id).offset(OFFSET)
      .pluck(:record_id).each_with_index do |record_id, index|

  validate record_id
  milestones index
end
