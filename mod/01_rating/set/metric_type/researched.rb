format :html do
  def default_content_formgroup_args args
    super(args)
    args[:edit_fields]['+value type'] = { title: 'Value Type'}
    args[:edit_fields]['+research policy'] = { title: 'Research Policy'}
  end

  def default_tabs_args args
    args[:tabs] = {
      'Details' => path(view: 'details_tab'),
      'Sources' => path(view: 'source_tab'),
      "#{fa_icon :comment} Discussion" => path(view: 'discussion_tab'),
      'Scores' => path(view: 'scores_tab')
    }
    args[:default_tab] = 'Details'
  end

  view :details_tab do
    output [
             nest(card.about_card, view: :titled, title: 'About'),
             nest(card.methodology_card, view: :titled, title: 'Methodology'),
             nest(card.value_type_card, view: :titled, item: :name,
                                        title: 'Value Type')
           ]
  end

  view :source_tab do
    <<-HTML
    <div class="row">
      <div class="row-icon">
        <i class="fa fa-globe"></i>
      </div>
      <div class="row-data">
        {{+source|titled;title:Sources;|content;structure:source_item}}
      </div>
    </div>
    HTML
  end

  view :scores_tab do
    'scores'
  end
end