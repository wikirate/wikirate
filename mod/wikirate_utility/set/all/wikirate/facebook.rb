format :html do
  def views_in_head
    super << :facebook_meta_tag
  end

  def facebook_agent?
    return false unless (agent = request&.user_agent)
    agent == "Facebot" || agent.include?("facebookexternalhit/1.1")
  end

  # TODO: move "facebook meta" handling from card to code
  view :facebook_meta_tag, cache: :never, unknown: true do
    return unless card.known? && facebook_agent?
    nest Card.fetch(card.name, "facebook meta"), view: :core
  end
end
