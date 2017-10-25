require File.expand_path("../../../config/environment",  __FILE__)
require "colorize"
require "json"
require "byebug"
require "rubygems"
require "csv"
accepted_snippet_name = {}

# Please do the clean up after this script

if ARGV.length < 2
  puts "Please include paths of metric mapping file and certh json".red
  puts "EX: ruby script/step_3_extract_metric_values.rb "\
       "script/metric/data/metric_snippet_mapping.csv "\
       "script/metric/data/certh.json".green
  exit
end

metric_mapping_file_path = ARGV[0]
certh_json = ARGV[1]

puts "Metric Mapping File Path: #{metric_mapping_file_path}"
puts "CERTH Json File Path: #{certh_json}"

CSV.foreach(metric_mapping_file_path, encoding: "windows-1251:utf-8", headers: true, header_converters: :symbol, converters: :all) do |row|
  if row[:snippet_name] && row[:snippet_provider]
    accepted_snippet_name["#{row[:snippet_provider]}+#{row[:snippet_name]}"] = "#{row[:designer]}+#{row[:name]}"
  end
end

headers = %w[metric company_name year value source].compact
result = {}

Card::Auth.current_id = Card.fetch_id "Richard Mills"
Card::Auth.as_bot do
  def get_aliases_hash
    company_array = []
    aliases_hash = {}
    aliases_cards = Card.search right: "aliases", left: { type_id: Card::WikirateCompanyID }
    aliases_cards.each do |aliases_card|
      aliases_card.item_names.each do |name|
        aliases_hash[name.downcase] = aliases_card.name.left
      end
      company_array.push(aliases_card.name.left.downcase)
    end
    [aliases_hash, company_array]
  end

  file_name = certh_json

  text = File.open(file_name).read
  text.gsub!(/\r\n?/, "\n")

  begin
    aliases_hash, company_array = get_aliases_hash
    puts "finished getting company aliases".green
    result_str = ""
    snippets_names = []

    json_array = JSON.parse(text)
    puts "start parsing json file".green
    json_array.each do |json_obj|
      _company = nil
      snippets = json_obj["Snippets"][0]
      company = json_obj["Company_name"]
      aliases = json_obj["Aliases"]
      aliases.delete_if { |a| a.strip == company }
      # company_aliases[company] = aliases.join("|")
      snippets.each do |value|
        source_name = value["source_name"]
        name = value["name"]

        next unless accepted_snippet_name.key?("#{source_name}+#{name}") &&
                    value.key?("citeyear")
        metric_name = accepted_snippet_name["#{source_name}+#{name}"]

        _value = value["value"] ? value["value"].to_s.gsub("\"", "\"\"") : ""
        source_link = value["source"]
        _company = nil
        if !company_array.include?(company.downcase)
          # puts company
          aliases.each do |_alias|
            if __company = aliases_hash[_alias.downcase]
              _company = __company
              break
            end
          end
        else
          _company = company
        end
        next if _company.nil?
        metric_name = accepted_snippet_name["#{source_name}+#{name}"]
        unless Card.exists?("#{metric_name}+#{_company}+#{value['citeyear']}")
          key = "\"#{metric_name}\",\"#{_company}\",\"#{value['citeyear']}\""
          result[key] = "\"#{_value}\",\"#{source_link}\""
        end
      end
    end

    snippets_names = snippets_names.uniq
    puts result.length

    result_str = "#{headers.join(',')}\n"
    result.each do |key, value|
      result_str += "#{key},#{value}\n"
    end
    File.open("script/metric/csv/metric_to_import.csv", "w") do |file|
      file.write(result_str)
    end
  rescue RuntimeError => bang
    raise "JSON parse error! #{bang}"
  end
end
