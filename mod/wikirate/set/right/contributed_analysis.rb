def contribution_count
  @cc ||= Card.search :type_id=>WikirateAnalysisID,
            :right_plus=>[ 'article', {:edited_by=>cardname.left }],
            :return=>:count
end

format :html do
  def default_header_args args
    with_inclusion_mode :normal do
      args[:icon] = nest Card.fetch('venn icon'), :view=>:core, :size=>:small
    end
  end

  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open triangle-right } : %w{ close closed triangle-bottom } )

    link_to  glyphicon(direction),
             path( :view=>adjective ),
             :remote => true,
             :title => "#{verb} #{card.name}",
             :class => "#{verb}-icon toggler slotter nodblclick #{'disabled' if card.contribution_count == 0}"
  end

  view :open do |args|
    if card.contribution_count == 0
      _render_closed(args)
    else
      if Auth.current_id == card.left.id
        args.merge! :slot_class=>'editable'
      end
      super(args)
    end
  end


  view :header do |args|
    %{
      <div class="card-header #{ args[:header_class] }">
        <div class="card-header-title #{ args[:title_class] }">
          #{ args[:icon] }
          #{ _optional_render :title, args }
          <span class="badge">#{card.contribution_count}</span>
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
