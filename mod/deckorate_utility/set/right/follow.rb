format :html do
  view :title do
    super() + render_more_link(optional: :hide)
  end

  view :more_link do
    link_to_card card, "more..."
  end

  #  view :profile, unknown: true do
  #    voo.show :more_link
  #    return "" unless card.left.present? && card.left.account
  #    frame { _render_following_list }
  #  end
end
