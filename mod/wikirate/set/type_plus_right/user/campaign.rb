format :html do

  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open triangle-right } : %w{ close closed triangle-bottom } )

    link_to  glyphicon(direction),
             path( :view=>adjective ),
             :remote => true,
             :title => "#{verb} #{card.name}",
             :class => "#{verb}-icon toggler slotter nodblclick"
  end

  def default_header_args args
    args[:count] = subformat(Card.fetch("#{card.cardname.left}+campaigns edited by+*count"))._render_core
    args[:icon] = (icon_card = Card.fetch "#{card.cardname.right}+icon") && subformat(icon_card)._render_core
  end

  view :header do |args|

    %{
      <div class="card-header #{ args[:header_class] }">
        <div class="card-header-title #{ args[:title_class] }">
          #{ args[:icon] }
          #{ _optional_render :title, args }
          <span class="badge">#{args[:count]}</span>
          <div class="pull-right">
            #{ _optional_render :toggle, args, :hide }
          </div>
        </div>
      </div>
      #{ _optional_render :toolbar, args, :hide}
      #{ _optional_render :edit_toolbar, args, :hide}
      #{ _optional_render :account_toolbar, args, :hide}
    }
  end
end