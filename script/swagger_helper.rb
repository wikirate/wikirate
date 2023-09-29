# Required Libraries
require File.expand_path("../config/environment", __dir__)
require "yaml"
require "json"

def deep_copy(hash)
  Marshal.load(Marshal.dump(hash))
end

# Helper Method: Extract Prefix
def extract_prefix(filename)
  filename.match(/\d+/)[0].to_i
end

# Helper Method: Get Values for Card Names
def card_name_values(card_names)
  values = []
  card_names.each do |name|
    name = name.to_name
    values.append(I18n.transliterate(name.url_key))
  end
  values
end

# Helper Method: Filter Option Values
def filter_option_values(base_codename, filter_name)
  puts "filter_option_values(#{base_codename}, #{filter_name})".blue
  card_name_values(base_codename.card.format.send("filter_#{filter_name}_options"))
end

def get_wikirate_cardtypes
  [:wikirate_company, :metric, :metric_answer, :relationship_answer, :source,
   :dataset, :wikirate_topic, :research_group, :company_group, :record]
end

def get_optional_subcards
  {
    :wikirate_company => Card::Set::Type::WikirateCompany::Export::NESTED_FIELD_CODENAMES,
    :metric => %w[question about methodology unit topics value_options research_policy report_type],
    :metric_answer => %w[comment unpublished],
    :relationship_answer => %w[comment unpublished],
    :source => %w[company report_type year file],
    :wikirate_topic => %w[overview],
    :research_group => %w[topics description organizer],
    :dataset => %w[description topics year company metric parent],
    :company_group => %w[topics about]
  }
end

def get_required_subcards
  {
    :wikirate_company => [],
    :metric_answer => %w[value source],
    :metric => %w[metric_type value_type],
    :relationship_answer => %w[value source],
    :source => %w[title link],
    :dataset => [],
    :wikirate_topic => [],
    :research_group => [],
    :company_group => []
  }
end

def get_cardname_descriptions
  descriptions = [
    "Given the company name. The company name it can be also substituted with its numerical `~id`.",
    "Given the source name. The source name it can be also substituted with its numerical `~id`.",
    "The name of a metric follows the pattern `Designer+Title`. For example: Core+Address. Any piece of the name can be substituted with its numerical id in the form of `~INTEGER`",
    "The name of an answer follows the pattern `Metric+Company+Year`. (Note, the name of a metric follows the pattern Designer+Title). Any piece of the name (or the entire name) can be substituted with its numerical id in the form of `~INTEGER`. Eg, if your metric's id is `867` and your company's id is `5309`, then you can address the answer as `~867+~5309+1981`",
    "The name of a relationship answer follows the pattern `Metric+Subject Company+Year+Object Company`. (Note, the name of a metric follows the pattern Designer+Title). Any piece of the name (or the entire name) can be substituted with its numerical id in the form of `~INTEGER`. Eg, if your metric's id is `2929009`, the subject company's id is `49209`, the object company's id is `12230576` then you can address the answer as `~14561838+~49209+2022+~12230576`",
    "Given the topic name. The topic name it can be also substituted with its numerical `~id`.",
    "Given the research group name. The research group name it can be also substituted with its numerical `~id`.",
    "Given the dataset name. The dataset name it can be also substituted with its numerical `~id`.",
    "Given the company group. The company group name it can be also substituted with its numerical `~id`.",
    "The name of a wikirate record follows the pattern `Metric+Company` and the metric the patter `Designer+Title`. For example: `US_Securities_and_Exchange_Commission+Assets+Microsoft_Corporation`. Any piece of the name can be substituted with its numerical id in the form of ~INTEGER."
  ]

  cardname_description = {}

  get_wikirate_cardtypes.each_with_index do |key, index|
    cardname_description[key] = descriptions[index]
  end
  cardname_description
end

def generate_swagger_spec input_schema, paths, parameters
  schemas = Hash.new

  schema_files = Dir['./script/swagger/schemas/*'].sort_by {
    |file| extract_prefix(File.basename(file))
  }
  schema_files.each do |f|
    schema = YAML.load_file("#{f}")
    if schemas == {}
      schemas = schema
    else
      schemas.merge!(schema)
    end
  end

  securitySchemes = {
    "apiKey" => {
      "type" => "apiKey",
      "in" => "header",
      "name" => "X-API-Key"
    }
  }

  swagger = {
    "openapi" => input_schema["openapi"],
    "info" => input_schema["info"],
    "tags" => input_schema["tags"],
    "servers" => input_schema["servers"],
    "externalDocs" => input_schema["externalDocs"],
    "paths" => paths,
    "components" => { "securitySchemes" => securitySchemes,
                      "parameters" => parameters,
                      "responses" => input_schema["components"]["responses"],
                      "schemas" => schemas
    }
  }

  File.open("./script/swagger/output_spec.yml", "w") do |file|
    file.write(swagger.to_yaml)
  end
end

def initialize_filter_parameters(parameters, wikirate_cardtypes)
  parameter_keys = []
  excluded_option_filters = [:year, :designer, :updated, :status, :dataset,
                             :company_group, :wikirate_topic, :country]
  wikirate_cardtypes.each do |cardtype|
    cardtype.card.format.filter_keys.each do |i|
      if not parameter_keys.include?("filter_by_#{i}")
        parameter_keys.append "filter_by_#{i}"
        begin
          enumerated_values = filter_option_values(cardtype, i)
          schema = { "type" => "string",
                     "enum" => enumerated_values }
          if excluded_option_filters.include?(i) || enumerated_values == []
            schema = { "type" => "string" }
          end
        rescue
          schema = { "type" => "string" }
        end

        parameters["filter_by_#{i}"] = { "name" => "filter[#{i}][]",
                                         "in" => "query",
                                         "required" => false,
                                         "description" => "filter results by #{i}#{i == :designer ? ', available designers can be found [here](https://wikirate.org/:designer)' : ''}",
                                         "schema" => schema }
      end
    end
  end
end

def initialize_path_parameters(parameters, wikirate_cardtypes, cardname_description)
  wikirate_cardtypes.each do |cardtype|
    parameters["#{cardtype.card.name.url_key.downcase}"] =
      { "name" => "#{cardtype.card.name.url_key.downcase}",
        "in" => 'path',
        "required" => true,
        "description" => cardname_description[cardtype],
        "schema" => { "type" => "string",
                      "example" => "#{cardtype_example(cardtype)}" } }
  end
end

def cardtype_example cardtype
  Card.search(type: cardtype, limit: 1).first.name.url_key
end
