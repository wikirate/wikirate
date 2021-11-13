include_set Abstract::Filterable

format :html do
  # BAR VIEWS
  before :bar do
    class_up "bar-left", "_filterable"
    super()
  end

  view(:bar_left) { filterable(source: card.name) { render_compact } }
  view(:bar_middle) { render_years }
  view(:bar_right) do
    [count_badge(:metric_answer), render_meatballs]
  end
  view :bar_bottom, template: :haml

  bar_cols 7, 5

  view :box_top do
    render_compact
  end

  view :box_middle do
    [render_years]
  end

  view :box_bottom, template: :haml
  view :meatballs, template: :haml

  # LINK AND BUTTON VIEWS
  view :close_icon, template: :haml
  view :years, template: :haml

  view :source_link, template: :haml
  view :title_link do
    link_to_card card, title_text, target: "_blank", title: card.wikirate_title,
                                   class: "source-preview-link preview-page-link"
  end

  # OTHER VIEWS

  view :creator_credit do
    wrap_with :div, class: "last-edit" do
      "added #{_render_created_at} ago by #{creator}"
    end
  end

  view :compact, template: :haml

  def year_list
    @year_list ||= card.year_card.item_names || []
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

  def creator
    return unless (creator_card = Card[card.creator_id])
    nest creator_card, view: :link
  end

  # DELETE?
  view :wikirate_copy_message, template: :haml
end
