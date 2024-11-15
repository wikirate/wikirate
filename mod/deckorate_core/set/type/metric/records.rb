# @return [Record::ActiveRecord_Relation]
def records args={}
  args[:metric_id] = id
  normalize_company_arg :company_id, args
  Record.where args
end

# @return [Record]
def latest_record company
  records(company: company, latest: true).take
end

# @return [Array] of Integers
def company_ids args={}
  records(args).distinct.pluck :company_id
end

# @return [Array] of Cards
def companies args={}
  company_ids(args).map { |id| Card[id] }
end

# @return [Array] of Integers
def record_ids args={}
  records(args).pluck :id
end

def record_for company, year
  Record.where(metric_id: id, company_id: company.card_id, year: year.to_i).take
end

private

def normalize_company_arg key, args={}
  return unless (company = args.delete :company)

  args[key] = company.card_id
end
