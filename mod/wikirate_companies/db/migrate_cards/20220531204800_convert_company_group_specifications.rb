# -*- encoding : utf-8 -*-

# company groups specification data representation changed from CSV to JSON
class ConvertCompanyGroupSpecifications < Cardio::Migration
  def up
    Card.search(left: { type: :company_group }, right: :specification).each do |spec|
      spec.update! content: new_constraints(spec) unless spec.explicit?
    end
  end

  def new_constraints spec
    spec.content.split(/\n+/).map { |constraint| new_constraint(constraint) }
  rescue StandardError => e
    puts "error updating company group specification for #{spec.name} (#{spec.id})".red
    puts e.message
    puts e.backtrace
  end

  def new_constraint constraint
    metric, year, value, group = CSV.parse_line(constraint)
    value = JSON.parse value if value
    { metric_id: metric.card_id, year: year, value: value, group: group }
  end
end
