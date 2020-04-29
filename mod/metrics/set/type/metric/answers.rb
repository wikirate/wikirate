# DEPRECATED
def all_answers
  answers
end

# @return [Answer]
def latest_answer company
  answers(company: company, latest: true).first
end

# @return [Answer::ActiveRecord_Relation]
def answers args={}
  args[:metric_id] = id
  normalize_company_arg :company_id, args
  Answer.where args
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

def random_answer_card
  Answer.search(metric_id: id, limit: 1).first
end

def answer_for company, year
  company = Card.fetch_id(company) unless company.is_a? Integer
  Answer.where(metric_id: id, company_id: company, year: year.to_i).take
end

def answer_name_for company, year
  Card::Name[name, Card.fetch_name(company), year.to_s]
end

private

def normalize_company_arg key, args={}
  return unless (company = args.delete :company)

  args[key] = Card.fetch_id company
end


# def answer_card company, year
#   field(company)&.field(year.to_s)
# end
#
# def value_cards _opts={}
#   Answer.search metric_id: id, return: :value_card
# end
