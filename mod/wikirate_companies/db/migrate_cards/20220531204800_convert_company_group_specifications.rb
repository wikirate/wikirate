# -*- encoding : utf-8 -*-

# company groups specification data representation changed from CSV to JSON
class ConvertCompanyGroupSpecifications < Cardio::Migration
  def up
    Card.search(left: { type: :company_group }, right: :specification).each do |spec|
      next if spec.explicit? || already_converted?(spec)

      reporting_error spec do
        spec.update! content: new_constraints(spec)
      end
    end
  end

  def already_converted? spec
    spec.content.first == "["
  end

  def new_constraints spec
    spec.content.split(/\n+/).map { |constraint| new_constraint(constraint) }
  end

  def reporting_error spec
    yield
  rescue StandardError => e
    puts "error updating company group specification for #{spec.name} (#{spec.id})".red
    puts e.message
    puts e.backtrace[0..10].join("\n")
  end

  def new_constraint constraint
    metric, year, value, group = CSV.parse_line(constraint)
    value = JSON.parse value if value
    { metric_id: metric.card_id, year: year, value: value, group: group }
  end
end
