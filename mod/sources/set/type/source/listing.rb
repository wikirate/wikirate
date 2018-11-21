format :html do
  view :bar_left, template: :haml

  view :bar_middle do
    count_badges :wikirate_company, :metric
  end

  view :bar_right, template: :haml

  view :bar_bottom do
    add_name_context
    output [render_bar_middle,
            field_nest(:report_type, view: :labeled,
                                     title: "Report Type",
                                     items: { view: :name }),
            field_nest(:wikirate_topic, view: :labeled,
                                        title: "Topics",
                                        items: { view: :link }),
            field_nest(:description, view: :titled, title: "Description")]
  end

  view :icon do
    icon = wrap_with(:i, " ", class: "glyphicon glyphicon-link")
    wrap_with(:div, icon, class: "source-icon")
  end

  view :creator_credit do
    wrap_with :div, class: "last-edit" do
      "added #{_render_created_at} ago by #{creator}"
    end
  end

  view :source_link do
    wrap_with :div, class: "source-link d-block" do
      [wrap_with(:div, source_title, class: "source-title"),
       wrap_with(:div, website_text, class: "source-website text-muted")]
    end
  end

  view :title_link do
    link_to_card card, title_text,
                 target: "_blank",
                 class: "source-preview-link preview-page-link"
  end

  view :listing_compact, template: :haml

  view :content do
    add_name_context
    super()
  end

  view :missing do
    _view_link
  end

  def year_list
    card.year_card.item_names || []
  end

  # make view of year?
  def year_icon
    wrap_with :span, fa_icon("calendar"), class: "pr-1"
  end


  def website_text
    field_nest :wikirate_website, view: :content, items: { view: :name }
  end

  def title_text
    field_nest :wikirate_title, view: :needed
  end

  def source_title
    voo.show?(:title_link) ? _render_title_link : title_text
  end

  def creator
    return unless (creator_card = Card[card.creator_id])
    field_nest creator_card, view: :link
  end
end
