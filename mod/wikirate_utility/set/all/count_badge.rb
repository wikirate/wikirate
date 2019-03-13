format do
  # note: overridden in cached_count
  def count
    card.count
  end
end

format :html do
  def count_badge field
    field_nest field, view: :count_badge, title: Card::Name[field].vary(:plural)
  end

  def count_badges *fields
    output(fields.map { |f| count_badge f })
  end

  view :count do
    count
  end

  # TODO: override and turn off caching in cacheable sets (eg pointers)
  view :count_badge, cache: :never, tags: :unknown_ok do
    labeled_badge count, render_title, klass: card.safe_set_keys
  end
end
