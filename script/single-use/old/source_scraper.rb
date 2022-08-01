#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

# This takes answer csv imports as inputs,
# cleans up the urls in the source field,
# and outputs a source import csv file.

require "csv"

project_dir = "/Users/ethan/Dropbox/FTI imports"
input_dir = "#{project_dir}/4ethan"
OUTPUT_DIR = "#{project_dir}/4laureen".freeze
input_suffix = "" # "Test"

def process_csv_row row
  urls = row["Source"].scan(/http\S+/)
  row["Source"] = urls.join " ; "
  urls.each do |url|
    add_source url, row["Company"], row["Year"]
  end
end

def add_source url, company, year
  hash = @source_hash[url] ||= {}
  hash[:company] ||= []
  hash[:company] << company
  hash[:year] ||= []
  hash[:year] << year
end

def output_csv name, suffix, csv_content
  File.write "#{OUTPUT_DIR}/#{name}-#{suffix}.csv", csv_content
end

def source_csv
  csv = ""
  @source_hash.each do |url, hash|
    csv << [semicolons(hash[:company]), semicolons(hash[:year]), nil, url, nil].to_csv
  end
  csv
end

def semicolons array
  array.uniq.join "; "
end

Dir.glob("#{input_dir}/*#{input_suffix}.csv").each do |filename|
  @source_hash = {}

  name = filename.match(/\/([^\/.]*)\.csv$/)[1]
  csv = CSV.read filename, headers: true
  csv.each do |row|
    process_csv_row row
  end
  # puts  @source_export.uniq.map(&:to_csv).join
  output_csv name, "clean", csv.to_csv
  output_csv name, "source", source_csv
end
