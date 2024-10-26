format :html do
  def count_label cat
    card = cat.card
    card.try(:count_label) || card.name.vary(:plural)
  end

  def count_categories
    raise StandardError, "must override #count_categories"
  end
  view :fancy_counts, template: :haml, cache: :deep, expire: :minute
end
