def record
  left
end

def metric_name
  record.metric_name
end

def project_years
  right&.years
end

def answers
  rel = record.answer_relation.order year: :desc
  if (years = project_years) && years.present?
    rel = rel.where year: years
  end
  rel.map(&:card)
end

format :html do
  view :metric_option, template: :haml, unknown: true

  view :metric_selected_option, unknown: true do
    nest card.metric_name, view: :research_option_header
  end

  # NOCACHE because item search
  view :years_and_values, cache: :never, unknown: true do
    card.answers.map do |a|
      nest a, view: :year_and_value
    end
  end
end
