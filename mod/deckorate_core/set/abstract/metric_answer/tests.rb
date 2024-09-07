
def researched_value?
  researched? || (hybrid? && answer&.answer_id)
end

def overridden?
  hybrid? && answer&.answer_id
end

def blank_overridden?
  overridden? && !answer.overridden_value.present?
end

def overridden_value?
  answer.overridden_value.present?
end

# Metric is calculated but this answer can't yet be calculated
def uncalculated?
  !researched? && answer.new_record?
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
