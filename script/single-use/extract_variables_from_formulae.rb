require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

NEST_REGEXP = /^\s*(?<variable>\w+)\s*=\s*\{\{(?<nest>[^}]*)\}\}\s*$/

def inspect_inputs inputs, formula
  puts "#{inputs.keys.size} found variables for #{formula.name.left}: " \
       "#{inputs.keys.join ', '}".green

  chunks = formula.nest_chunks
  inspect_nest_count inputs, chunks.size, formula
  inspect_nest_options chunks, formula
end

def inspect_nest_count inputs, nest_count, formula
  return if inputs.keys.size == nest_count

  puts "expected #{formula.nest_chunks.size} variables from " \
       "/#{formula.name.url_key} :\n#{formula.content}".red
end

def inspect_nest_options chunks, formula
  opts = chunks.map { |n| n.options.except :nest_name, :nest_syntax }.uniq
  puts opts

  @option_groups[opts] ||= []
  @option_groups[opts] << formula

  return unless opts.size > 1

  puts "nest options vary! " # ":\n#{formula.content}".yellow
end

def strip_coffeescript_comment fcontent
  fcontent.sub /^#\s*CoffeeScript\s*/m, ""
end

def each_javascript_formula
  Card.search left: { type: :metric }, right: :formula do |formula|
    yield formula if formula.calculator_class == Calculate::JavaScript
  end
end

def inputs_from_formula fcontent
  inputs = {}
  fcontent.each_line do |line|
    break unless (match = line.match NEST_REGEXP)
    inputs[match[:variable]] = match[:nest]
  end
  inputs
end

def inspect_all
  @option_groups = {}
  each_javascript_formula do |formula|
    fcontent = strip_coffeescript_comment formula.content
    inputs = inputs_from_formula fcontent
    inspect_inputs inputs, formula
  end
end
