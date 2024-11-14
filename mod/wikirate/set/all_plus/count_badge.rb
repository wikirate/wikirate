include_set Abstract::BsBadge

format :html do
  def count_badge_label
    card.name.right_name.vary(:plural)
  end

  view :count_badge, cache: :never, unknown: true do
    labeled_badge number_with_delimiter(count),
                  nest(card.right, view: :count_badge_label),
                  klass: card.safe_set_keys, title: count_badge_label
  end
end
