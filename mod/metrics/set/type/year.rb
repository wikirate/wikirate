YEAR_REGEXP = /^\d{4}$/

event :validate_year_name, :validate, on: :save do
  errors.add :name, "invalid year" unless name.to_s.match? YEAR_REGEXP
end

format :html do
  view :in_calendar, unknown: true, template: :haml
end
