format :html do

  view :title do |args|
    res = super(args)
    res += optional_render :more_link, args, :hide
  end

  view :more_link do |args|
    card_link card, :text=> 'more...'
  end

  view :profile do |args|
    frame args.merge(:optional_more_link=>:show) do
      _render_following_list(args)
    end
  end
end