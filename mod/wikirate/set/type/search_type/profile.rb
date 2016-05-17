format :html do
  view :open_profile do |args|
    _render_open(args)
  end

  view :header do |args|
    icon_card = Card.fetch("#{card.cardname.right}+icon")
    icon = icon_card ? "<i class='fa fa-#{icon_card.content}></i>" : ""
    if args[:home_view] == :open_profile
      %(
        <div class="card-header #{args[:header_class]}">
          <div class="card-header-title #{args[:title_class]}">
            #{icon}
            #{_optional_render :title, args}
            #{_optional_render :toggle, args, :hide}
          </div>
        </div>
        #{_optional_render :toolbar, args, :hide}
      )
    else
      super(args)
    end
  end
end
