class Card
  # find for a fixed company all metrics without metric answers
  module MissingAnswerQuery
    class FixedMetric < AllAnswerQuery::FixedMetric
      include MissingAnswerQuery::Shared
    end
  end
end