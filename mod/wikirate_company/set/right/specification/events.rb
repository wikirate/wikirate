event :validate_constraints, :validate, on: :save do
  return if explicit?
  standardize_constraint_csv
  err = constraint_error
  errors.add :content, "Invalid specifications: #{err}" if err
end

event :update_company_list, :prepare_to_store, on: :save do
  return if explicit?

  company_list.update_content_from_spec
end

private

def company_list
  left&.subfield(:wikirate_company) || left&.add_subfield(:wikirate_company)
end

def standardize_constraint_csv
  return unless content.match? ";|;"

  self.content = js_generated_csv_to_array.map(&:to_csv).join
end

# The JavaScript generates a kind of half-way csv.
# The values are separated by ";|;" instead of ",".  This means that we don't
# have to deal with escaping commas, etc.
def js_generated_csv_to_array
  content.split("\n").map do |row|
    row_array = row.split ";|;"
    row_array[2] = serialized_value_to_json row_array[2]
    row_array
  end
end

# The JavaScript handles doesn't get into interpreting the answer value constraints
# Instead, it serializes them into a string like
# "filter%5Bvalue%5D%5Bfrom%5D=30&filter%5Bvalue%5D%5Bto%5D="
#
# This method interprets that string, plucks out the value we want, and generates
# json for it.
def serialized_value_to_json raw_value
  return unless raw_value.present?

  hash = Rack::Utils.parse_nested_query CGI.unescape(raw_value)
  hash.dig("filter", "value")&.to_json
end

def constraint_error
  constraints.each(&:validate!)
  false
rescue StandardError => e
  e.message
end
