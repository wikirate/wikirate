# @return [Answer::ActiveRecord_Relation]
def answers args={}
  args[:metric_id] = id
  normalize_company_arg :company_id, args
  ::Answer.where args
end

# @return [Answer]
def latest_answer company
  answers(company: company, latest: true).take
end

# @return [Array] of Integers
def company_ids args={}
  answers(args).distinct.pluck :company_id
end

# @return [Array] of Cards
def companies args={}
  company_ids(args).map { |id| Card[id] }
end

# @return [Array] of Integers
def answer_ids args={}
  answers(args).pluck :id
end

def answer_for company, year
  ::Answer.where(metric_id: id, company_id: company.card_id, year: year.to_i).take
end

private

def normalize_company_arg key, args={}
  return unless (company = args.delete :company)

  args[key] = company.card_id
end
