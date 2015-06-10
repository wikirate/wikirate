format :html do
  def default_header_args args
    args[:count] = Card.search :type_id=>WikirateAnalysisID,
                    :right_plus=>[ 'article', {:or=>{:created_by=>card.left.name, :edited_by=>card.left.name }}],
                    :return=>:count
    args[:icon] = nest(Card.fetch('venn icon'), :view=>:core, :size=>:icon)
  end

  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open triangle-right } : %w{ close closed triangle-bottom } )

    link_to  glyphicon(direction),
             path( :view=>adjective ),
             :remote => true,
             :title => "#{verb} #{card.name}",
             :class => "#{verb}-icon toggler slotter nodblclick"
  end

  view :open do |args|
    if Auth.current_id == card.left.id
      args.merge! :slot_class=>'editable'
    end
    super(args)
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
