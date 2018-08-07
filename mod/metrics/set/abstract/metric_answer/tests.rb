def researched_value?
  researched? || (hybrid? && answer&.answer_id)
end

def overridden?
  hybrid? && answer&.answer_id
end

def blank_overridden?
  overridden? && !answer.overridden_value.present?
end

def calculation_overridden?
  overridden? && answer.overridden_value.present?
end

# Metric is researchable and this answer not yet researched
def research_ready?
  (researched? || hybrid?) && unknown?
end

# Metric is calculated but this answer can't yet be calculated
def uncalculated?
  !researched? && answer.new_record?
end

def inverse?
  metric_card.inverse?
end

format do
  delegate :calculation_overridden?, :researched_value?,
           :research_ready?, :uncalculated?, :inverse?,
           to: :card
end
