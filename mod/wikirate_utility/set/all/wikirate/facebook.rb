format :html do
  def views_in_head
    super << :facebook_meta_tag
  end

  # TODO: move "facebook meta" handling from card to code
  view :facebook_meta_tag, cache: :never, unknown: true do
    return unless card.known?

    nest Card.fetch(card.name, "facebook meta"), view: :core
  end
end
