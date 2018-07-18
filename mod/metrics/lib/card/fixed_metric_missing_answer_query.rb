class Card
  # find for a fixed metric all companies without metric answers
  class FixedMetricMissingAnswerQuery < MissingAnswerQuery
    include FixedMetric
  end
end
