YEAR_REGEXP = /^\d{4}$/

event :validate_year_content, :validate, on: :save do
  errors.add :content, "invalid year" unless name.to_s.match? YEAR_REGEXP
end

format :html do
  view :in_calendar, unknown: true, template: :haml
end
