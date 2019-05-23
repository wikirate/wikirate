class Card
  # find for a fixed company all metrics without metric answers
  module MissingAnswerQuery
    class FixedCompany < AllAnswerQuery::FixedCompany
      include MissingAnswerQuery::Shared
    end
  end
end
