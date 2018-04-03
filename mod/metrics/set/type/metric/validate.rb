event :ensure_two_parts, :validate, changed: :name do
  if name.parts.size < 2
    errors.add :name, "at least two parts are required"
  end
end