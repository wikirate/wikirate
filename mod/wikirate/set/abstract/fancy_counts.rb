format :html do
  def count_categories
    raise StandardError, "must override #count_categories"
  end
  view :fancy_counts, template: :haml
end