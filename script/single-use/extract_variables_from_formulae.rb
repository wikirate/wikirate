require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

NEST_REGEXP = /^\s*(?<variable>\w+)\s*=\s*\{\{(?<nest>[^}]*)\}\}\s*$/


def inspect_inputs inputs, formula
  puts "#{inputs.keys.size} found variables for #{formula.name.left}: " \
       "#{inputs.keys.join ', '}".green
  if inputs.keys.size != formula.nest_chunks.size
    puts "expected #{formula.nest_chunks.size} variables from " \
    "/#{formula.name.url_key} :\n#{formula.content}".red
  end
end

def strip_coffeescript_comment fcontent
  fcontent.sub /^#\s*CoffeeScript\s*/m, ""
end

Card.search left: { type: :metric }, right: :formula do |formula|
  next unless formula.calculator_class == Calculate::JavaScript

  fcontent = strip_coffeescript_comment formula.content
  inputs = {}

  fcontent.each_line do |line|
    break unless (match = line.match NEST_REGEXP)
    inputs[match[:variable]] = match[:nest]
  end

  inspect_inputs inputs, formula
end
