include_set Abstract::CachedTypeOptions

YEAR_REGEXP = /^\d{4}$/

def self.all_years
  @all_years ||= Card.search type: :year, return: :name, sort: :name, dir: :desc
end

event :validate_year_name, :validate, on: :save do
  errors.add :name, "invalid year" unless name.to_s.match? YEAR_REGEXP
end

format :html do
  view :in_calendar, unknown: true, template: :haml
end

def inapplicable_metric_ids
  Card.search(
    type: :metric,
    return: :id,
    limit: 0,
    right_plus: [
      :year,
      { not: { refer_to: id } }
    ]
  )
end
