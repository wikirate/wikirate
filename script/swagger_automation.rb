# Required Libraries
require File.expand_path("../config/environment", __dir__)
require 'yaml'
require 'json'

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
  card_name_values(base_codename.card.format.send("filter_#{filter_name}_options"))
end

# Sign in with Card::Auth.signin
Card::Auth.signin "Ethan McCutchen"

# List of Vowels
vowels = %w[a e i o u]

# Load Input Schema
input_schema = YAML.load_file("./script/swagger/input_spec.yml")

# List of Wikirate Card Types
wikirate_cardtypes = [:wikirate_company,
                      :metric,
                      :metric_answer,
                      :relationship_answer,
                      :source,
                      :dataset,
                      :wikirate_topic,
                      :research_group,
                      :company_group,
                      :record]

# Descriptions for different wikirate cardtypes
cardname_description = { :wikirate_company => "Given the company name. The company name it can be also substituted with its numerical `~id`.",
                         :source => "Given the source name. The source name it can be also substituted with its numerical `~id`.",
                         :metric => "The name of a metric follows the pattern `Designer+Title`. For example: Core+Address. Any piece of the name can be substituted with its numerical id in the form of `~INTEGER`",
                         :metric_answer => "The name of an answer follows the pattern `Metric+Company+Year`. (Note, the name of a metric follows the pattern Designer+Title). Any piece of the name (or the entire name) can be substituted with its numerical id in the form of `~INTEGER`. Eg, if your metric's id is `867` and your company's id is `5309`, then you can address the answer as `~867+~5309+1981`",
                         :relationship_answer => "The name of a relationship answer follows the pattern `Metric+Subject Company+Year+Object Company`. (Note, the name of a metric follows the pattern Designer+Title). Any piece of the name (or the entire name) can be substituted with its numerical id in the form of `~INTEGER`. Eg, if your metric's id is `2929009`, the subject company's id is `49209`, the object company's id is `12230576` then you can address the answer as `~14561838+~49209+2022+~12230576`",
                         :wikirate_topic => "Given the topic name. The topic name it can be also substituted with its numerical `~id`. ",
                         :research_group => "Given the research group name. The research group name it can be also substituted with its numerical `~id`.",
                         :dataset => "Given the dataset name. The dataset name it can be also substituted with its numerical `~id`. ",
                         :company_group => "Given the company group. The company group name it can be also substituted with its numerical `~id`. ",
                         :record => "The name of a wikirate record follows the pattern `Metric+Company` and the metric the patter `Designer+Title`. For example: `US_Securities_and_Exchange_Commission+Assets+Microsoft_Corporation`. Any piece of the name can be substituted with its numerical id in the form of ~INTEGER."}

# Required and Optional Subcards on create and updates of specific cardtypes
required_subcards = {
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
optional_subcards = {
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

# Extract Parameters from Input Schema
parameters = input_schema["components"]["parameters"]

# Extract Parameters from Input Schema
paths = input_schema["paths"]

parameter_keys = []

# Iterate through Card Types
wikirate_cardtypes.each do |cardtype|
  cardtype.card.format.filter_keys.each do |i|
    if not parameter_keys.include?("filter_by_#{i}")
      parameter_keys.append "filter_by_#{i}"
      begin
        enumerated_values = filter_option_values(cardtype, i)
        schema = { "type" => 'string',
                   "enum" => enumerated_values }
        if [:year, :designer, :updated, :status].include?(i) || enumerated_values == []
          schema = { "type" => 'string' }
        end
      rescue
        schema = { "type" => 'string' }
      end

      parameters["filter_by_#{i}"] = { "name" => "filter[#{i}][]",
                                       "in" => 'query',
                                       "required" => false,
                                       "description" => "filter results by #{i}#{i == :designer ? ', available designers can be found [here](https://wikirate.org/:designer)' : ''}",
                                       "schema" => schema }
    end
  end
end

wikirate_cardtypes.each do |cardtype|

  parameters["#{cardtype.card.name.url_key.downcase}"] =
    { "name" => "#{cardtype.card.name.url_key.downcase}",
      "in" => 'path',
      "required" => true,
      "description" => cardname_description[cardtype],
      "schema" => { "type" => 'string',
                    "example" => "#{::Card::fetch(cardtype).item_names[0].url_key}" } }
end

wikirate_cardtypes.each do |cardtype|
  p = [{ "$ref" => "#/components/parameters/format" },
       { "$ref" => "#/components/parameters/limit" },
       { "$ref" => "#/components/parameters/offset" }]
  cardtype.card.format.filter_keys.each do |i|
    p.append("$ref" => "#/components/parameters/filter_by_#{i}")
  end

  description = cardtype.card.fetch(:description)&.content
  plural_cardname = cardtype.card.name.to_s.to_name.vary(:plural).to_name.url_key
  cardtype_name = cardtype.card.name.url_key.downcase
  paths["/#{plural_cardname}"] = {
    "get" => {
      "tags" => ["Wikirate"],
      "description" => description.nil? || description.empty? ? "No description available" : description,
      "security" => [{ "apiKey" => [] }],
      "parameters" => p,
      "responses" => {
        "200" => {
          "description" => "paged list of all #{plural_cardname.downcase} under items in atom view.",
          "content" => {
            "application/json" => {
              "schema" => {
                "properties" => {
                  "id" => {
                    "type" => "integer"
                  },
                  "name" => {
                    "type" => "string"
                  },
                  "type" => {
                    "$ref" => "#/components/schemas/nucleus_view"
                  },
                  "url" => {
                    "type" => "string"
                  },
                  "codename" => {
                    "type" => "string"
                  },
                  "items" => {
                    "type" => "array",
                    "items" => {
                      "$ref" => "#/components/schemas/#{cardtype_name.downcase == 'data_set' ? 'dataset' : cardtype_name.downcase}_atom_view"
                    }
                  },
                  "links" => {
                    "type" => "array",
                    "items" => {
                      "type" => "string"
                    }
                  },
                  "ancestors" => {
                    "type" => "array",
                    "items" => {
                      "$ref" => "#/components/schemas/atom_view"
                    }
                  },
                  "html_url" => {
                    "type" => "string"
                  },
                  "created_at" => {
                    "type" => "string"
                  },
                  "updated_at" => {
                    "type" => "string"
                  },
                  "requested_at" => {
                    "type" => "string"
                  },
                  "license" => {
                    "type" => "string"
                  },
                  "paging" => {
                    "type" => "object",
                    "properties" => {
                      "next" => {
                        "type" => "string"
                      },
                      "previous" => {
                        "type" => "string"
                      }
                    }
                  }
                }
              },
              "example" => JSON.parse(File.read("./script/swagger/responses/200/#{plural_cardname.downcase == 'data_sets' ? 'datasets' : plural_cardname.downcase}.json"))
            }
          }
        }
      }
    }
  }

  if plural_cardname == "Answers"
    metric_answers_params = deep_copy paths["/#{plural_cardname}"]["get"]["parameters"]
    metric_answers_params.unshift({"$ref" => "#/components/parameters/metric"})
    paths["/{metric}+#{plural_cardname}"] = deep_copy paths["/#{plural_cardname}"]
    paths["/{metric}+#{plural_cardname}"]["get"]["parameters"] = metric_answers_params
    paths["/{metric}+#{plural_cardname}"]["get"]["description"] = "Returns the answers of the specified metric."
    paths["/{metric}+#{plural_cardname}"]["get"]["responses"]["200"]["content"]["application/json" ]["schema"]["example"] = JSON.parse(File.read("./script/swagger/responses/200/Metric+Answers.json"))

    company_answers_params = deep_copy paths["/#{plural_cardname}"]["get"]["parameters"]
    company_answers_params.unshift({"$ref" => "#/components/parameters/company"})
    paths["/{company}+#{plural_cardname}"] = deep_copy paths["/#{plural_cardname}"]
    paths["/{company}+#{plural_cardname}"]["get"]["parameters"] = company_answers_params
    paths["/{company}+#{plural_cardname}"]["get"]["description"] = "Returns the answers of the specified company."
    paths["/{company}+#{plural_cardname}"]["get"]["responses"]["200"]["content"]["application/json" ]["schema"]["example"] = JSON.parse(File.read("./script/swagger/responses/200/Company+Answers.json"))

  end
  article = "a"
  if vowels.include? cardtype_name[0]
    article = "an"
  end
  p = [{ "$ref" => "#/components/parameters/#{cardtype_name}" }, { "$ref" => "#/components/parameters/format" }]
  paths["/{#{cardtype_name}}"] = {
    "get" => {
      "tags" => ["Wikirate"],
      "summary" => "returns #{article} #{cardtype_name} given its name or wikirate id",
      "description" => description.nil? || description.empty? ? "No description available" : description,
      "parameters" => p,
      "responses" => {
        "200" => {
          "description" => "default JSON molecule view of the card `#{cardtype_name}`",
          "content" => {
            "application/json" => {
              "schema" => { "$ref" => "#/components/schemas/#{cardtype_name.downcase == 'data_set' ? 'dataset' : cardtype_name.downcase}_molecule_view" },
              "example" => JSON.parse(File.read("./script/swagger/responses/200/#{cardtype_name.downcase == 'data_set' ? 'dataset' : cardtype_name.downcase}.json"))
            }
          }
        },
        "404" => {
          "description" => "Not Found. The requested `#{cardtype_name}` card could not be found."
        },
        "401" => {
          "description" => "Unauthorized"
        },
        "500" => {
          "description" => "Internal Server Error"
        }
      }
    }
  }

  if cardtype == :record
    next
  end

  p = []
  if cardtype_name != "Source"
    p.append({ "name" => "#{cardtype_name}",
               "in" => 'path',
               "required" => true,
               "description" => cardname_description[cardtype],
               "schema" => { "type" => 'string' }
             })
  end

  required_subcards[cardtype].each do |parameter|
    begin
      enumerated_values = filter_option_values(cardtype, parameter)
      schema = { "type" => 'string',
                 "enum" => enumerated_values }
    rescue
      schema = { "type" => 'string' }
    end
    p.append({
               "name" => "card[subcard][+#{parameter}]",
               "in" => 'query',
               "required" => true,
               "schema" => schema
             })
  end

  optional_subcards[cardtype].each do |parameter|
    begin
      enumerated_values = filter_option_values(cardtype, parameter)
      schema = { "type" => 'string',
                 "enum" => enumerated_values }
      if parameter == "year" || enumerated_values == []
        schema = { "type" => 'string' }
      end
    rescue
      schema = { "type" => 'string' }
    end
    p.append({
               "name" => "card[subcard][+#{parameter}]",
               "in" => 'query',
               "required" => false,
               "schema" => schema
             })
  end

  paths["/{#{cardtype_name}}"]["put"] = {
    "tags" => ["Wikirate"],
    "summary" => "update #{article} #{cardtype_name} Card",
    "security" => [{ "apiKey" => [] }],
    "description" => "",
    "parameters" => p,
    "responses" => {
      "302" => {
        "description" => "Successful non-idempotent requests redirect to idempotent GET requests"
      },
      "404" => {
        "description" => "Not Found. The requested #{cardtype_name} card could not be found."
      },
      "401" => {
        "description" => "Unauthorized"
      },
      "500" => {
        "description" => "Internal Server Error"
      }
    }
  }

  params = deep_copy p
  params[0] = { "name" => "card[name]",
                "in" => 'query',
                "required" => true,
                "description" => cardname_description[cardtype],
                "schema" => { "type" => 'string' }
  }
  paths["/type/#{cardtype_name}"] = {
    "post" => {
      "tags" => ["Wikirate"],
      "summary" => "create #{article} #{cardtype_name} Card",
      "security" => [{ "apiKey" => [] }],
      "description" => "",
      "parameters" => params,
      "responses" => {
        "302" => {
          "description" => "Successful non-idempotent requests redirect to idempotent GET requests"
        },
        "401" => {
          "description" => "Unauthorized"
        },
        "500" => {
          "description" => "Internal Server Error"
        }
      }
    }
  }
end

schemas = Hash.new

schema_files =  Dir['./script/swagger/schemas/*'].sort_by{
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

File.open("./script/swagger/output_spec.yml", "w") { |file| file.write(swagger.to_yaml) }