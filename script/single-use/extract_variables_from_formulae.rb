require File.expand_path "../../../config/environment", __FILE__
require "json"
require "colorize"

Card::Auth.signin "Ethan McCutchen"
Card::Auth.as_bot

Cardio.config.perform_deliveries = false

include Card::Model::SaveHelper


NEST_REGEXP = /^\s*(?<variable>\w+)\s*=\s*(?<nest>\{\{[^}]*\}\})\s*$/

ensure_code_card "Rubric"

Card.search(left: {type: :metric}, right: :variables).each do |v|
  v.delete! unless v.type_code == :json
end

%i[year not_researched company].each { |k| Card::View::Options.shark_keys << k }

def strip_coffeescript_comment fcontent
  fcontent.sub /^#\s*CoffeeScript\s*/m, ""
end

def variables_and_formula metric
  { variables: [], formula: [] }.tap do |fields|
    strip_coffeescript_comment(metric.formula).each_line do |line|
      interpret_formula_line line, fields
    end
    fields[:formula] = fields[:formula].join("\n").strip
  end
end

def interpret_formula_line line, fields
  if (match = line.match NEST_REGEXP)
    fields[:variables] << variablize(match)
  else
    fields[:formula] << line
  end
end

def variablize match
  hash = { name: match[:variable] }
  nest = Card::Content::Chunk::Nest.new match[:nest], nil
  hash[:metric] = nest.name
  hash.merge nest.interpret_options
end

def update_calculations
  Card.search type: :metric, right_plus: :formula do |metric|
    begin
      send "update_#{metric.metric_type_codename}", metric
    rescue => e
      puts "error updating #{metric.name.url_key} (#{metric.id}): #{e.message}".red
    end
  end
end

def variables_only metric
  variables = yield.to_json
  # puts "variables for #{metric.name}: #{variables}".green
  metric.variables_card.update! content: variables
  metric.formula_card.delete!
end

def update_descendant metric
  variables_only metric do
    metric.formula.gsub(/[\[\]]/, "").split("\n").map do |metric|
      { metric: metric }
    end
  end
end

def update_rating metric
  variables_only metric do
    JSON.parse(metric.formula).each_with_object([]) do |(metric, weight), arr|
      arr << { metric: metric, weight: weight }
    end
  end
end

def update_score metric
  if metric.categorical?
    new_name = [metric, :rubric].cardname
    # puts "renaming #{metric.formula_card.name} to #{new_name}".magenta
    metric.formula_card.update! type: :json
    metric.formula_card.update! name: new_name
  else
    update_coffeescript_score metric
  end
end

def update_coffeescript_score metric
  update_coffeescript metric, :light_blue do
    variables_and_formula(metric).tap do |fields|
      next unless (varname = fields.delete(:variables).first&.dig :name)
      fields[:formula].gsub! /\b#{varname}\b/, "answer"
      if fields[:formula].lines.size == 1
        fields[:formula].sub! /^answer =\s*/, ""
      end
    end
  end
end

def update_coffeescript metric, color
  fields = yield
  # puts "fields for #{metric.name}: #{fields}".send color
  metric.update! fields: fields
  metric.formula_card.update! type: :coffee_script
end

def update_formula metric
  update_coffeescript metric, :cyan do
    variables_and_formula(metric).tap do |fields|
      fields[:variables] = fields[:variables].to_json
    end
  end
end

update_calculations
