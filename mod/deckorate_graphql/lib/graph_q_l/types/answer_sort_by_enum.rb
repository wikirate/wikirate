module GraphQL
  module Types
    # MetricSortByEnum enumerates all available options when sorting metric cards
    class AnswerSortByEnum < BaseEnum
      value :metric_designer, value: :metric_designer
      value :metric_name, value: :metric_title
      value :year, value: :year
      value :value, value: :value
    end
  end
end
