#!/usr/bin/env ruby
#
require "csv"

project_dir = "/Users/ethan/Dropbox/FTI imports"
input_dir = "#{project_dir}/4ethan"
OUTPUT_DIR = "#{project_dir}/4laureen"
input_suffix = "" # "Test"

@source_export = []

def process_csv_row row
  urls = row["Source"].scan(/http\S+/)
  row["Source"] = urls.join " ; "
  urls.each do |url|
    @source_export << [row["Company"], row["Year"], nil, url, nil]
  end
end

def output_csv name, suffix, csv_content
  File.write "#{OUTPUT_DIR}/#{name}-#{suffix}.csv", csv_content
end

Dir.glob("#{input_dir}/*#{input_suffix}.csv").each do |filename|
  name = filename.match(/\/([^\/.]*)\.csv$/)[1]
  csv = CSV.read filename, headers: true
  csv.each do |row|
    process_csv_row row
  end
  # puts  @source_export.uniq.map(&:to_csv).join
  output_csv name, "clean", csv.to_csv
  output_csv name, "source", @source_export.uniq.map(&:to_csv).join
end

