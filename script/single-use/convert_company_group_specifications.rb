# -*- encoding : utf-8 -*-

require File.expand_path "../../../config/environment", __FILE__
require "json"
require "csv"
require "colorize"

Card::Auth.signin "Ethan McCutchen"

def already_converted? spec
  spec.content.first == "["
end

def new_constraints spec
  spec.content.split(/\n+/).map { |constraint| new_constraint(constraint) }
end

def reporting spec
  updating = "updating company group specification for #{spec.name} (#{spec.id})"
  puts updating.green
  yield
rescue StandardError => e
  puts "ERROR while #{updating}".red
  puts e.message
  puts e.backtrace[0..10].join("\n")
end

def new_constraint constraint
  metric, year, value, group = CSV.parse_line(constraint)
  value = JSON.parse value if value
  metric = "Walk Free" if metric == "Walk Free Foundation"
  { metric_id: metric.card_id, year: year, value: value, related_company_group: group }
end

Card.search(left: { type: :company_group }, right: :specification).each do |spec|
  next if spec.explicit? || already_converted?(spec)

  reporting spec do
    spec.update! content: new_constraints(spec)
  end
end
