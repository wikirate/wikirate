class Card
  module MissingAnswerQuery
    # query not-researched answers for a given company
    class FixedCompany < AllAnswerQuery::FixedCompany
      include MissingAnswerQuery::Shared
    end
  end
end
