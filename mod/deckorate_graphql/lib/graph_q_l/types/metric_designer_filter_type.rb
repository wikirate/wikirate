module GraphQL
  module Types
    class MetricDesignerFilterType < BaseEnum
      ::Metric.select(:designer_id).distinct.each do |metric|
        value ::Card.fetch(metric.designer_id).card.name.url_key, value: ::Card.fetch(metric.designer_id).card.name
      end
    end
  end
end