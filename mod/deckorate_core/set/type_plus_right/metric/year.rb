include_set Abstract::Applicability

def ok_item_types
  :year
end

def inapplicable_answers
  researched_answers.where.not year: item_names
end

format :html do
  def input_type
    :multiselect
  end
end
