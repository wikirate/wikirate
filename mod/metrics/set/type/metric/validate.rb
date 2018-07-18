event :ensure_two_parts, :validate, changed: :name do
  errors.add :name, "at least two parts are required" if name.parts.size < 2
end
