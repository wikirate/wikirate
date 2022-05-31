# -*- encoding : utf-8 -*-

# company groups specification data representation changed from CSV to JSON
class ConvertCompanyGroupSpecifications < Cardio::Migration
  def up
    Card.search(left: { type: :company_group }, right: :specification).each do |spec|
      next if spec.explicit?

      constraints = content.split(/\n+/).map do |constraint|
        metric, year, value, group = CSV.parse_line(constraint)
        { metric_id: metric.card_id, year: year, value: JSON.parse(value), group: group }
      end

      spec.update! content: constraints
    end
  end
end
