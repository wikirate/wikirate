require File.expand_path("../../../config/environment",  __FILE__)
require File.expand_path("../../wikirate_import_shared", __FILE__)
require "colorize"
require "json"
require "byebug"
require "rubygems"
require "csv"

file_name = "script/metric/data/certh.json"

text = File.open(file_name).read

def company_skip_list
  %w[BROO Off ACE SAS WPS]
end

def snippet_information json_obj
  [json_obj["Snippets"][0], json_obj["Company_name"], json_obj["Aliases"]]
end

def parse_report_source json_array, aliases_hash, skip_list
  result = []
  json_array.each do |json_obj|
    snippets, company, aliases = snippet_information json_obj
    snippets.each do |value|
      next if value["name"] != "Conflict Minerals Report"
      cite_year = value["citeyear"]
      url = value["value"]

      correct_name =
        correct_company_name company, aliases, aliases_hash, skip_list

      result.push "\"#{url}\",\"#{correct_name}\",\"#{cite_year}\","\
                    '"Conflict Minerals Report"'
    end
  end
  result
end

begin
  library_card = Card.new type_id: Card::MetricValueImportFileID
  aliases_hash = library_card.format.aliases_hash
  skip_list = company_skip_list
  json_array = JSON.parse(text)
  result = parse_report_source json_array, aliases_hash, skip_list

  write_array_to_file "script/metric/data/sources1.csv", result
rescue => error
  puts error.message.to_s.red
end
