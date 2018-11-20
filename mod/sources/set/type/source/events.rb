
event :check_source, :validate, on: :create do
  errors.add :source, "file required" unless subfield :file
end
