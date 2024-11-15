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
  record.unpublished
end

# this record is calculated
def calculated_unpublished
  direct_dependee_records.find(&:unpublished).present?
end
