format :html do
  def count_badge field
    field_nest field, view: :count_badge, title: Card::Name[field].vary(:plural)
  end

  def count_badges *fields
    output fields.map { |f| count_badge f }
  end

  def count
    card.count
  end

  view :count do
    count
  end

  view :count_badge do
    labeled_badge count, render_title, klass: card.safe_set_keys
  end
end
