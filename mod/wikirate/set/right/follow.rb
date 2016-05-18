format :html do
  view :title do |args|
    res = super(args)
    res += optional_render :more_link, args, :hide
  end

  view :more_link do |_args|
    card_link card, text: "more..."
  end

  view :profile, tags: :unknown_ok do |args|
    if card.left.present? && card.left.account
      frame args.merge(optional_more_link: :show) do
        _render_following_list(args)
      end
    else
      ""
    end
  end
end
