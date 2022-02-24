require File.expand_path "../../../config/environment", __FILE__
require "json"
require "colorize"

Card::Auth.signin "Ethan McCutchen"
config.perform_deliveries = false


NEST_REGEXP = /^\s*(?<variable>\w+)\s*=\s*\{\{(?<nest>[^}]*)\}\}\s*$/

# def inspect_inputs inputs, formula
#   puts "#{inputs.keys.size} found variables for #{formula.name.left}: " \
#        "#{inputs.keys.join ', '}".green
#
#   chunks = formula.nest_chunks
#   inspect_nest_count inputs, chunks.size, formula
#   inspect_nest_options chunks, formula
# end

# def inspect_nest_count inputs, nest_count, formula
#   return if inputs.keys.size == nest_count
#
#   puts "expected #{formula.nest_chunks.size} variables from " \
#        "/#{formula.name.url_key} :\n#{formula.content}".red
# end
#
# def inspect_nest_options chunks, formula
#   opts = chunks.map { |n| n.options.except :nest_name, :nest_syntax }.uniq
#   puts opts
#
#   @option_groups[opts] ||= []
#   @option_groups[opts] << formula
#
#   return unless opts.size > 1
#
#   puts "nest options vary! " # ":\n#{formula.content}".yellow
# end

def strip_coffeescript_comment fcontent
  fcontent.sub /^#\s*CoffeeScript\s*/m, ""
end

def variables_and_formula metric
  vars = {}
  formula = []

  strip_coffeescript_comment(metric.formula).each_line do |line|
    if (match = line.match NEST_REGEXP)
      vars[match[:variable]] = match[:nest]
    else
      formula << line
    end
  end
  { variables: vars, formula: formula.join("\n").strip }
end

def update_calculations
  Card.search type: :metric, right_plus: :formula do |metric|
    begin
      send "update_#{metric.metric_type_codename}"
    rescue => e
      puts "error updating #{metric.name} (#{metric.id)}: #{e.message}".red
    end
  end
end

def variables_only metric
  variables = yield.to_json
  puts "variables for #{metric.name}: #{variables}".green
  #metric.variables_card.update! content: variables
  #metric.formula_card.delete!
end

def update_descendant metric
  variables_only metric do
    metric.formula.gsub(/[\[\]]/, "").split("\n").map do |metric|
      { metric: metric }
    end
  end
end

def update_wiki_rating metric
  variables_only metric do
    JSON.parse(metric.formula).each_with_object([]) do |(metric, weight), arr|
      arr << { metric: metric, weight: weight }
    end
  end
end

def update_score metric
  if metric.categorical?
    new_name = [metric, :rubric].cardname
    puts "renaming #{metric.formula_card.name} to #{new_name}".yellow
    # metric.formula_card.update! name: new_name
  else
    update_coffeescript metric do
      variables_and_formula(metric).tap { |fields| fields.delete :variables }
    end
  end
end

def update_coffeescript metric
  subfields = yield
  puts "subfields for #{metric.name}: #{subfields}".blue
  # metric.update! subfields
  # metric.formula_card.update! type: :coffeescript
end


def update_formula metric
  update_coffeescript metric do
    variables_and_formula metric
  end
end


update_calculations
