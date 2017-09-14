class Card
  # find for a fixed company all metrics without metric answers
  class FixedCompanyMissingAnswerQuery < MissingAnswerQuery
    include FixedCompany
  end
end
