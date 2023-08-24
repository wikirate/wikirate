card_accessor :reference, type: :search_type

format :html do
  def bar_menu_items
    super.insert 3, attribution_link(text: "Attribute")
  end

  def menu_items
    super.unshift attribution_link
  end

  def history_view
    :history_and_references
  end

  def attribution_link text: ""
    # , button: false
    modal_link "#{icon_tag :attribution} #{text}",
               size: :large,
               # class: ("btn btn-primary" if button),
               path: { mark: :reference,
                       action: :new,
                       card: { fields: { ":subject": card.name,
                                         ":party": Auth.current_card&.name } } }
  end

  view :history_and_references do
    tabs "Contributions" => { content: render_history(hide: :title) },
         "References" => { content: field_nest(:reference, view: :core) }
  end

  view :attributions do
    tabs "Rich Text" => { content: render_rich_text_attrib },
         "Plain Text" => { content:  render_plain_text_attrib },
         "HTML" => { content: render_html_attrib }
  end

  view :rich_text_attrib do
    attribution_box { render_attribution }
  end

  view :plain_text_attrib do
    attribution_box { card.format(:text).render_attribution }
  end

  view :html_attrib do
    attribution_box { "html attribution" }
  end

  # placeholder
  def attribution_box
    yield
  end

  view :att_wikirate do
    link_to "Wikirate.org", href: "https://wikirate.org"
  end

  view :att_title do
    render_title_link
  end
end

format do
  view :attribution do
    [:wikirate, :title].map do |section|
      render "att_#{section}"
    end.join ", "
  end

  view :att_wikirate do
    "Wikirate.org"
  end

  view :att_title do
    "#{render_title} (#{render_id_url})"
  end
end
