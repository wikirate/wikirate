def name_part_types
  %w[metric company year]
end

event :set_answer_name, before: :set_autoname, when: :invalid_answer_name? do
  new_name = compose_and_validate_name
  abort :failure if errors.any?
  self.name = new_name
end

def compose_and_validate_name
  name_part_types.map do |type|
    fetch_name_part type
  end.join "+"
end

def fetch_name_part type
  name_part = name_part_from_field(type) || name_part_from_name(type)
  check_name_part type, name_part
end

def name_part_from_name type
  return unless send("valid_#{type}?")
  send type
end

def name_part_from_field type
  field = remove_subfield type
  return unless field&.content.present?
  field.content.gsub("[[", "").gsub("]]", "")
end
