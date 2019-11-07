# require File.expand_path("../../config/environment",  __FILE__)

require_relative "../../config/environment"
require "pry"

FILENAME = "/tmp/invalid_options.csv"
SITE = "http://staging.wikirate.org"
OFFSET = 187000

Card::Auth.as_bot
@seq = 0
@bad = 0

def track_validity val
  @seq += 1
  return if @seq < OFFSET # can't use offset with find_each
  puts "TRACK SEQ: #{@seq}" if @seq % 1000 == 0

  return if val.valid?

  @bad += 1
  record_invalid val, "INVALID", val.content
rescue StandardError => e
  record_invalid val, "ERROR", e.message
end

def record_invalid val, type, msg
  puts "#{@bad}/#{@seq} #{type}: #{SITE}/#{val.name.url_key}"
  File.open FILENAME, "a" do |file|
    file.puts "#{type},#{val.name.url_key},#{msg}"
  end
end

Card.where(right_id: Card::ValueID, trash: false).order(:name).find_each do |val|
  track_validity val
end
