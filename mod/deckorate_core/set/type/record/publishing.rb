include_set Abstract::Publishable

def unpublished
  if metric_card&.unpublished
    true
  elsif researched_value?
    super
  elsif relation?
    false
  else
    calculated_unpublished
  end
end

def unpublished?
  answer.unpublished
end

# this answer is calculated
def calculated_unpublished
  direct_dependee_answers.find(&:unpublished).present?
end
