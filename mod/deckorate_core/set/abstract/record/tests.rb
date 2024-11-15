
def researched_value?
  researched? || (hybrid? && record&.record_id)
end

def overridden?
  hybrid? && record&.record_id
end

def blank_overridden?
  overridden? && !record.overridden_value.present?
end

def overridden_value?
  record.overridden_value.present?
end

# Metric is calculated but this record can't yet be calculated
def uncalculated?
  !researched? && record.new_record?
end

def inverse?
  metric_card.inverse?
end

def researchable?
  metric_card.researchable?
end

format do
  delegate :overridden?, :overridden_value?, :researched_value?,
           :uncalculated?, :inverse?,
           to: :card
end
