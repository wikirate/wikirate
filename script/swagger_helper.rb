# Required Libraries
require File.expand_path("../config/environment", __dir__)
require "yaml"
require "json"

EXTRA_FILTER_HELP = {
  designer: ", available designers can be found [here](https://wikirate.org/:designer)"
}.freeze

def deep_copy hash
  Marshal.load Marshal.dump(hash)
end

# Helper Method: Extract Prefix
def extract_prefix filename
  filename.match(/\d+/)[0].to_i
end

# Helper Method: Get Values for Card Names
def card_name_values card_names
  values = []
  card_names.each do |name|
    name = name.to_name
    values.append(I18n.transliterate(name.url_key))
  end
  values
end

# Helper Method: Filter Option Values
def filter_option_values base_codename, filter_name
  puts "filter_option_values(#{base_codename}, #{filter_name})".blue
  card_name_values base_codename.card.filter_option_values(filter_name)
end

def fetch_wikirate_cardtypes
  %i[company metric answer relationship source
     dataset topic research_group company_group record]
end

def fetch_optional_subcards
  {
    company: Card.new(type: :company).simple_field_names,
    metric: %w[question about methodology unit topics value_options assessment
               report_type],
    answer: %w[comment unpublished],
    relationship: %w[comment unpublished],
    source: %w[company report_type year file],
    topic: %w[overview],
    research_group: %w[topics description organizer],
    dataset: %w[description topics year company metric parent],
    company_group: %w[topics about]
  }
end

def fetch_required_subcards
  {
    company: [],
    answer: %w[value source],
    metric: %w[metric_type value_type],
    relationship: %w[value source],
    source: %w[title link],
    dataset: [],
    topic: [],
    research_group: [],
    company_group: []
  }
end

def fetch_security_schemes
  {
    "apiKey" => {
      "type" => "apiKey",
      "in" => "header",
      "name" => "X-API-Key"
    }
  }
end

def fetch_cardname_descriptions
  descriptions = File.readlines("./script/swagger/cardnames_desc.txt").map(&:chomp)

  cardname_description = {}

  fetch_wikirate_cardtypes.each_with_index do |key, index|
    cardname_description[key] = descriptions[index]
  end
  cardname_description
end

def fetch_schemas
  schemas = {}

  dir = Dir["./script/swagger/schemas/*"]
  schema_files = dir.sort_by { |file| extract_prefix(File.basename(file)) }
  schema_files.each do |f|
    schemas = schemas == {} ? YAML.load_file(f) : schemas.merge!(YAML.load_file(f))
  end
  schemas
end

def generate_swagger_spec input_schema, paths, parameters
  swagger = {
    "openapi" => input_schema["openapi"],
    "info" => input_schema["info"],
    "tags" => input_schema["tags"],
    "servers" => input_schema["servers"],
    "externalDocs" => input_schema["externalDocs"],
    "paths" => paths,
    "components" => { "securitySchemes" => fetch_security_schemes,
                      "parameters" => parameters,
                      "responses" => input_schema["components"]["responses"],
                      "schemas" => fetch_schemas }
  }

  File.open("./script/swagger/output_spec.yml", "w") do |file|
    file.write(swagger.to_yaml)
  end
end

def fetch_filter_param_schema cardtype, filter
  excluded_option_filters = %i[year designer updated status dataset
                               company_group topic country]
  begin
    enumerated_values = filter_option_values(cardtype, filter)
    schema = { "type" => "string", "enum" => enumerated_values }
    if enumerated_values.empty? || excluded_option_filters.include?(filter)
      schema = { "type" => "string" }
    end
  rescue ArgumentError
    schema = { "type" => "string" }
  end
  schema
end

def initialize_filter_parameters parameters, wikirate_cardtypes
  parameter_keys = []

  wikirate_cardtypes.each do |cardtype|
    cardtype.card.format.filter_keys.each do |i|
      parameter_key = "filter_by_#{i}"
      next if parameter_keys.include?(parameter_key)
      parameters[parameter_key] = {
        "name" => "filter[#{i}][]",
        "in" => "query",
        "required" => false,
        "description" => "filter results by #{i}#{EXTRA_FILTER_HELP[i]}",
        "schema" => fetch_filter_param_schema(cardtype, i)
      }
      parameter_keys << parameter_key
    end
  end
end

def initialize_path_parameters parameters, wikirate_cardtypes, cardname_description
  wikirate_cardtypes.each do |cardtype|
    parameters[cardtype.card.name.url_key.downcase] =
      { "name" => cardtype.card.name.url_key.downcase,
        "in" => "path",
        "required" => true,
        "description" => cardname_description[cardtype],
        "schema" => { "type" => "string",
                      "example" => cardtype_example(cardtype) } }
  end
end

def cardtype_example cardtype
  Card.search(type: cardtype, limit: 1).first.name.url_key
end
