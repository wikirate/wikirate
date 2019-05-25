class Card
  module MissingAnswerQuery
    # query not-researched answers for a given metric
    class FixedMetric < AllAnswerQuery::FixedMetric
      include MissingAnswerQuery::Shared
    end
  end
end
