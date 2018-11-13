require File.expand_path("../../../config/environment",  __FILE__)
require File.expand_path("../../wikirate_import_shared", __FILE__)

require "colorize"
require "json"
require "rubygems"
require "csv"

file_name = "script/metric/data/sources.csv"

def create_company company
  return if Card.exists? company
  Card.create! name: company, type_id: Card::WikirateCompanyID
end

def description company, year
  "This source links to the SD form filed with the SEC by #{company} in "\
  "#{year} - they usually include a Conflict Minerals Report, but may "\
  "also be a statement of why the company is not required to submit a "\
  "Conflict Minerals Report. Section 1502 of the Dodd-Frank Act makes "\
  "submitting a Conflict Minerals Report mandatory for companies that "\
  "manufacture products requiring Tin, Tantalum, Tungsten or Gold "\
  '(3TG, or "Conflict Minerals").'
end

def source_args url, report_type, year, company
  actual_year = (year.to_i - 1).to_s
  {
    type_id: Card::SourceID,
    subcards: {
      "+File" => { type_id: Card::FileID, remote_file_url: url },
      "+report_type" => report_type,
      "+year" => actual_year,
      "+company" => "[[#{company}]]",
      "+title" => "#{company} Conflict Minerals Report - #{actual_year}",
      "+Topics" => "[[Conflict Minerals]]\n[[Dodd-Frank]]\n[[SEC]]\n",
      "+description" => description(company, year)
    }
  }
end

def find_duplicated url
  duplicates = Card::Set::Self::Source.find_duplicates url
  return duplicates[0] if duplicates.any?
end

def extract_info row
  [row[0], row[1], row[2], row[3]]
end

def create_source row
  url, company, year, report_type = extract_info(row)
  arg = source_args(url, report_type, year, company)
  if (source_card = find_duplicated(url))
    puts "#{source_card.name} #{url} is created".yellow
  else
    puts arg.to_s.green
    Card.create! arg
  end
end

Card::Auth.as_bot do
  silent_mode do
    CSV.foreach(file_name, encoding: "windows-1251:utf-8",
                           headers: false) do |row|
      create_company row[1]
      create_source row
    end
  end
end
