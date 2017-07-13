def name_parts
  %w[metric company year]
end

event :set_answer_name,
      before: :set_autoname, when: :invalid_value_name? do
  new_name = compose_and_validate_name
  abort :failure if errors.any?
  self.name = new_name
end

def compose_and_validate_name
  name_parts.map do |part|
    fetch_name_part part
  end.join "+"
end

def fetch_name_part part
  name_part = name_part_from_field(part) || name_part_from_name(part)
  check_name_part part, name_part
end

def name_part_from_name part
  return unless send("valid_#{part}?")
  send part
end

def name_part_from_field part
  field = remove_subfield part
  return unless field && field.content.present?
  field.content.gsub("[[", "").gsub("]]", "")
end
