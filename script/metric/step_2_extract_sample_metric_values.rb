require "rubygems"
require "json"
require "byebug"
require "net/http"
require "uri"
require "colorize"

# source name, snippet name = value, company name, source link
json_array = []
full_json = ""
result = {}
result_count = {}
year_exist = {}

file_name = "data/certh.json"

text = File.open(file_name).read

begin
  snippets_names = []

  json_array = JSON.parse(text)

  json_array.each do |json_obj|
    snippets = json_obj["Snippets"][0]
    company = json_obj["Company_name"]
    snippets.each do |value|
      name = value["name"]
      _value = value["value"] ? value["value"].to_s.gsub("\"", "\"\"") : ""
      source_name = value["source_name"]
      source_link = value["source"]

      unless result.key?"\"#{source_name}\",\"#{name}\""
        result["\"#{source_name}\",\"#{name}\""] = "\"#{_value}\",\"#{company}\",\"#{source_link}\""
        result_count["\"#{source_name}\",\"#{name}\""] = 0
        year_exist["\"#{source_name}\",\"#{name}\""] = -1
      end
      count = result_count["\"#{source_name}\",\"#{name}\""]
      count += 1
      result_count["\"#{source_name}\",\"#{name}\""] = count

      _year_exist = year_exist["\"#{source_name}\",\"#{name}\""]
      has_year = value.key?"citeyear"
      if _year_exist == -1
        year_exist["\"#{source_name}\",\"#{name}\""] = has_year ? 1 : 0
      elsif _year_exist != 2
        if _year_exist == 1 && !has_year
          year_exist["\"#{source_name}\",\"#{name}\""] = 2
        end
        if _year_exist == 0 && has_year
          year_exist["\"#{source_name}\",\"#{name}\""] = 2
        end
      end
      snippets_names.push(value["name"])
    end
  end

  snippets_names = snippets_names.uniq
  puts result.length
  result_str = ""
  result.each do |key, array|
    result_str += "#{key},#{array},#{result_count[key]},#{year_exist[key]}\n"
  end
  File.open("data/sample_metric_values.csv", "w") { |file| file.write(result_str) }
rescue RuntimeError => bang
  raise "JSON parse error! #{bang}"
end
