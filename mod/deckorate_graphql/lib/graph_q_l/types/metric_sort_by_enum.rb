module GraphQL
  module Types
    # MetricSortByEnum enumerates all available options when sorting metric cards
    class MetricSortByEnum < BaseEnum
      value :metric_designer, value: :metric_designer
      value :metric_name, value: :metric_title
      value :metric_bookmarkers, value: :metric_bookmarkers
    end
  end
end
