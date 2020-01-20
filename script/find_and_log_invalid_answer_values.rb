# require File.expand_path("../../config/environment",  __FILE__)

require_relative "../../config/environment"

FILENAME = "/tmp/invalid_answer_values.csv".freeze
SITE = "".freeze
OFFSET = 0

Card::Auth.as_bot
@seq = 0

def track_validity val
  with_seq_tracking do
    record_invalid val, "INVALID", val.content unless val.valid?
  end
rescue StandardError => e
  record_invalid val, "ERROR", e.message
end

def with_seq_tracking
  @seq += 1
  return if @seq < OFFSET
  #  can't use offset with find_each

  puts "TRACK SEQ: #{@seq}" if (@seq % 1000).zero?
  yield
end

def record_invalid val, type, msg
  puts "#{@seq} #{type}: #{SITE}/#{val.name.url_key}"
  File.open FILENAME, "a" do |file|
    file.puts "#{type},#{val.name.url_key},#{msg}"
  end
end

Card.where(right_id: Card::ValueID, trash: false).find_each do |val|
  track_validity val
end
