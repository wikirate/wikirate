format do
  # note: overridden in cached_count
  def count
    card.respond_to?(:count) ? card.count : 0
  end
end

format :html do
  def count_badge field
    field_nest field, view: :count_badge
  end

  def count_badge_label
    responsive_count_badge_label || simple_count_badge_label
  end

  def responsive_count_badge_label
    return unless (field = card.right&.codename) && (icon_tag = mapped_icon_tag(field))

    haml :responsive_count_badge_label, icon_tag: icon_tag
  end

  def simple_count_badge_label
    card.name.right_name.vary(:plural)
  end

  def count_badges *fields
    fields.map { |f| count_badge f }
  end

  view :count do
    count
  end

  # TODO: override and turn off caching in cacheable sets (eg pointers)
  view :count_badge, cache: :never, unknown: true do
    labeled_badge count, count_badge_label, klass: card.safe_set_keys
  end
end
