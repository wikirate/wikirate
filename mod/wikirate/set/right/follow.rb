format :html do
  view :title do
    voo.hide :more_link
    res = super()
    res + render_more_link
  end

  view :more_link do
    link_to_card card, "more..."
  end

  view :profile, tags: :unknown_ok do
    voo.show :more_link
    return "" unless card.left.present? && card.left.account
    frame { _render_following_list }
  end
end
