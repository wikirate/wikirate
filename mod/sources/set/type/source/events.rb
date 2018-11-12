
event :check_source, :validate, on: :create do
  unless subfield :file
    errors.add :source, "Source file required"
  end
end
