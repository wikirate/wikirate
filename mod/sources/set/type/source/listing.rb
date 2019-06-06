include_set Abstract::Filterable

format :html do
  # BAR VIEWS
  before :bar do
    class_up "bar-left", "_filterable"
    super()
  end

  view :bar_left do
    filterable :source do
      haml :bar_left
    end
  end

  view :bar_right, template: :haml

  view :bar_middle do
    count_badges :metric_answer, :metric, :wikirate_company
  end

  view :bar_bottom do
    [badge_header,
     labeled_field(:report_type),
     labeled_field(:wikirate_topic, :link, title: "Topics"),
     field_nest(:description, view: :titled)]
  end

  def badge_header
    wrap_with :div, class: "d-flex justify-content-center pb-3" do
      render_bar_middle
    end
  end

  bar_cols 7, 5

  view :cite_bar, template: :haml
  view :preview_link_bar, template: :haml

  # LINK AND BUTTON VIEWS

  # download and original links.  (view makes them hideable)
  view :links, template: :haml

  view :cite_button, template: :haml
  view :uncite_button, template: :haml
  view :freshen_button, template: :haml

  view :close_icon, template: :haml

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

  # OTHER VIEWS

  view :creator_credit do
    wrap_with :div, class: "last-edit" do
      "added #{_render_created_at} ago by #{creator}"
    end
  end

  # TODO: unify with bar-left
  view :listing_compact, template: :haml
  view :wikirate_copy_message, template: :haml

  def year_list
    card.year_card.item_names || []
  end

  # make view of year?
  def year_icon
    wrap_with :span, fa_icon("calendar"), class: "pr-1"
  end

  def website_text
    return "" unless card.wikirate_website_card.content.present?
    field_nest :wikirate_website, view: :content, items: { view: :name }
  end

  def title_text
    field_nest :wikirate_title, view: :needed
  end

  def source_title
    voo.show?(:title_link) ? _render_title_link : title_text
  end

  def hidden_item_input
    tag :input, type: "hidden", class: "_pointer-item", value: card.name
  end

  def creator
    return unless (creator_card = Card[card.creator_id])
    nest creator_card, view: :link
  end
end
