include_set Abstract::Applicability

def inapplicable_answers
  researched_answers.where.not year: item_names
end

format :html do
  def input_type
    :multiselect
  end
end
