def contribution_count
  @cc ||= Card.search(
    type_id: WikirateAnalysisID,
    right_plus: [Card[:overview].name, { edited_by: cardname.left }],
    return: :count
  )
end

format :html do
  def default_header_args args
    with_nest_mode :normal do
      args[:icon] = nest Card.fetch("venn icon"), view: :core, size: :small
    end
  end

  def toggle_verb_adjective_direction
    if @toggle_mode == :close
      %w(open open triangle-right)
    else
      %w(close closed triangle-bottom)
    end
  end

  view :open do
    if card.contribution_count.zero?
      _render_closed
    else
      if (l = card.left) &&
         (Auth.current_id == l.id || l.type_code == :wikirate_company)
        class_up "card-slot", "editable"
      end
      super()
    end
  end

  view :header do |args|
    %(
      <div class="card-header #{args[:header_class]}">
        <div class="card-header-title #{args[:title_class]}">
          #{args[:icon]}
          #{_optional_render :title, args}
          <span class="badge">#{card.contribution_count}</span>
          <div class="pull-right">
            #{_optional_render :toggle, args, :hide}
          </div>
        </div>
      </div>
      #{_optional_render :toolbar, args, :hide}
    )
  end
end
