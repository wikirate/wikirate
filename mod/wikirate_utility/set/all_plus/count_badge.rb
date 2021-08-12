include_set Abstract::BsBadge

# TODO: override and turn off caching in cacheable sets (eg. pointers)
view :count_badge, cache: :never, unknown: true do
  labeled_badge number_with_delimiter(count),
                nest(card.right, view: :count_badge_label),
                klass: card.safe_set_keys, title: card.name.right_name.vary(:plural)
end
