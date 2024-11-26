# Required Libraries
require File.expand_path("../config/environment", __dir__)
require_relative "swagger_helper"
require "colorize"

# Sign in with Card::Auth.signin
Card::Auth.signin "Ethan McCutchen"

# List of Vowels
vowels = %w[a e i o u]

# Load Input Schema
input_schema = YAML.load_file("./script/swagger/input_spec.yml")

# List of Wikirate Card Types
wikirate_cardtypes = fetch_wikirate_cardtypes

# Descriptions for different wikirate cardtypes
cardname_description = fetch_cardname_descriptions

# Required and Optional Subcards on create and updates of specific cardtypes
required_subcards = fetch_required_subcards
optional_subcards = fetch_optional_subcards

# Extract Parameters from Input Schema
parameters = input_schema["components"]["parameters"]

# Extract Path from Input Schema
paths = input_schema["paths"]

puts "initialize filter parameters"
initialize_filter_parameters(parameters, wikirate_cardtypes)

puts "initialize path parameters"
initialize_path_parameters(parameters, wikirate_cardtypes, cardname_description)

wikirate_cardtypes.each do |cardtype|
  puts "working on cardtype: #{cardtype}".green

  p = [{ "$ref" => "#/components/parameters/format" },
       { "$ref" => "#/components/parameters/limit" },
       { "$ref" => "#/components/parameters/offset" }]
  cardtype.card.format.filter_keys.each do |i|
    p.append("$ref" => "#/components/parameters/filter_by_#{i}")
  end

  description = cardtype.card.fetch(:description)&.content || "No description available"
  plural_cardname = cardtype.card.name.to_s.to_name.vary(:plural).to_name.url_key
  cardtype_name = cardtype.card.name.url_key.downcase
  example_json =
    File.read "./script/swagger/responses/200/#{plural_cardname.downcase}.json"

  puts "working on /#{plural_cardname} paths"
  paths["/#{plural_cardname}"] = {
    "get" => {
      "tags" => ["Wikirate"],
      "description" => description,
      "security" => [{ "apiKey" => [] }],
      "parameters" => p,
      "responses" => {
        "200" => {
          "description" =>
            "paged list of all #{plural_cardname.downcase} under items in atom view.",
          "content" => {
            "application/json" => {
              "schema" => {
                "properties" => {
                  "id" => { "type" => "integer" },
                  "name" => { "type" => "string" },
                  "type" => { "$ref" => "#/components/schemas/nucleus_view" },
                  "url" => { "type" => "string" },
                  "codename" => { "type" => "string" },
                  "items" => {
                    "type" => "array",
                    "items" => {
                      "$ref" => "#/components/schemas/#{cardtype_name.downcase}_atom_view"
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
                  "html_url" => { "type" => "string" },
                  "created_at" => { "type" => "string" },
                  "updated_at" => { "type" => "string" },
                  "requested_at" => { "type" => "string" },
                  "license" => { "type" => "string" },
                  "paging" => {
                    "type" => "object",
                    "properties" => {
                      "next" => { "type" => "string" },
                      "previous" => { "type" => "string" }
                    }
                  }
                }
              },
              "example" => JSON.parse(example_json)
            }
          }
        }
      }
    }
  }

  if plural_cardname == "Answers"
    puts "working on special Answer paths"

    answer_params = deep_copy paths["/#{plural_cardname}"]["get"]["parameters"]
    answer_params.unshift("$ref" => "#/components/parameters/metric")
    mfieldpaths =
      paths["/{metric}+#{plural_cardname}"] =
        deep_copy(paths["/#{plural_cardname}"])

    mfieldget = mfieldpaths["get"]
    mfieldget["parameters"] = answer_params
    mfieldget["description"] = "Returns the answer of the specified metric."
    mfieldget["responses"]["200"]["content"]["application/json"]["schema"]["example"] =
      JSON.parse(File.read("./script/swagger/responses/200/Metric+Answers.json"))

    company_answers_params = deep_copy paths["/#{plural_cardname}"]["get"]["parameters"]
    company_answers_params.unshift("$ref" => "#/components/parameters/company")
    company_answers_path = "/{company}+#{plural_cardname}"
    cfieldpaths = paths[company_answers_path] = deep_copy(paths["/#{plural_cardname}"])
    cfieldget = cfieldpaths["get"]
    cfieldget["parameters"] = company_answers_params
    cfieldget["description"] = "Returns the answer of the specified company."

    cfieldget["responses"]["200"]["content"]["application/json"]["schema"]["example"] =
      JSON.parse(File.read("./script/swagger/responses/200/Company+Answers.json"))

  end
  article = vowels.include?(cardtype_name[0]) ? "an" : "a"

  p = [
    { "$ref" => "#/components/parameters/#{cardtype_name}" },
    { "$ref" => "#/components/parameters/format" }
  ]

  puts "working on /#{cardtype_name} paths"
  paths["/{#{cardtype_name}}"] = {
    "get" => {
      "tags" => ["Wikirate"],
      "summary" => "returns #{article} #{cardtype_name} given its name or wikirate id",
      "description" => description.blank? ? "No description available" : description,
      "parameters" => p,
      "responses" => {
        "200" => {
          "description" => "default JSON molecule view of the card `#{cardtype_name}`",
          "content" => {
            "application/json" => {
              "schema" => {
                "$ref" => "#/components/schemas/#{cardtype_name.downcase}_molecule_view"
              },
              "example" =>
                JSON.parse(
                  File.read(
                    "./script/swagger/responses/200/#{cardtype_name.downcase}.json"
                  )
                )
            }
          }
        },
        "404" => {
          "description" =>
            "Not Found. The requested `#{cardtype_name}` card could not be found."
        },
        "401" => { "description" => "Unauthorized" },
        "500" => { "description" => "Internal Server Error" }
      }
    }
  }

  next if cardtype == :record

  p = []
  if cardtype_name != "Source"
    p.append("name" => cardtype_name,
             "in" => "path",
             "required" => true,
             "description" => cardname_description[cardtype],
             "schema" => { "type" => "string" })
  end

  required_subcards[cardtype].each do |parameter|
    begin
      enumerated_values = filter_option_values(cardtype, parameter)
      schema = { "type" => "string",
                 "enum" => enumerated_values }
    rescue ArgumentError
      schema = { "type" => "string" }
    end
    p.append("name" => "card[subcard][+#{parameter}]",
             "in" => "query",
             "required" => true,
             "schema" => schema)
  end

  optional_subcards[cardtype].each do |parameter|
    begin
      enumerated_values = filter_option_values(cardtype, parameter)
      schema = { "type" => "string", "enum" => enumerated_values }
      schema = { "type" => "string" } if parameter == "year" || enumerated_values == []
    rescue ArgumentError
      schema = { "type" => "string" }
    end
    p.append("name" => "card[subcard][+#{parameter}]",
             "in" => "query",
             "required" => false,
             "schema" => schema)
  end

  paths["/{#{cardtype_name}}"]["put"] = {
    "tags" => ["Wikirate"],
    "summary" => "update #{article} #{cardtype_name} Card",
    "security" => [{ "apiKey" => [] }],
    "description" => "",
    "parameters" => p,
    "responses" => {
      "302" => {
        "description" =>
          "Successful non-idempotent requests redirect to idempotent GET requests"
      },
      "404" => {
        "description" =>
          "Not Found. The requested #{cardtype_name} card could not be found."
      },
      "401" => {
        "description" => "Unauthorized"
      },
      "500" => { "description" => "Internal Server Error" }
    }
  }

  params = deep_copy p
  params[0] = { "name" => "card[name]",
                "in" => "query",
                "required" => true,
                "description" => cardname_description[cardtype],
                "schema" => { "type" => "string" } }
  paths["/type/#{cardtype_name}"] = {
    "post" => {
      "tags" => ["Wikirate"],
      "summary" => "create #{article} #{cardtype_name} Card",
      "security" => [{ "apiKey" => [] }],
      "description" => "",
      "parameters" => params,
      "responses" => {
        "302" => {
          "description" =>
            "Successful non-idempotent requests redirect to idempotent GET requests"
        },
        "401" => { "description" => "Unauthorized" },
        "500" => { "description" => "Internal Server Error" }
      }
    }
  }
end

generate_swagger_spec input_schema, paths, parameters
