include_set CategoryValue

format :html do
  def editor
    options_count > 10 ? :multiselect : :checkbox
  end
end
