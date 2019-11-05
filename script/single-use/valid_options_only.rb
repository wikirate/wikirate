# require File.expand_path("../../config/environment",  __FILE__)

require_relative "../../config/environment"
require "pry"

FILENAME = "/tmp/invalid_options.rb"
SITE = "http://staging.wikirate.org"

Card::Auth.as_bot
@bad = 0
@seq = 0

def track_validity val
  @seq += 1
  next if val.valid?

  @bad += 1
  record_invalid val
end

def record_invalid val
  @file.write "#{@bad}/#{@seq},#{SITE}/#{val.name.url_key},#{val.content}"
end

File.open FILENAME, "w+" do |file|
  @file = file
  Card.where(right_id: Card::ValueID).find_each do |val|
    track_validity val
  end
end
