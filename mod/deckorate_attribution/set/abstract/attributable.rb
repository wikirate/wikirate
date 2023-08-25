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
    attribution_box { h render_attribution }
  end

  # placeholder
  def attribution_box
    yield
  end

  view :att_wikirate do
    link_to "Wikirate.org", href: "https://wikirate.org", target: "_blank"
  end

  def attribution_link text, url
    link_to text, href: url, target: "_blank"
  end
end

format do
  view :attribution do
    %i[wikirate title license].map do |section|
      render "att_#{section}"
    end.join ", "
  end

  view :att_wikirate do
    "Wikirate.org"
  end

  view :att_title do
    attribution_link card.name, render_id_url
  end

  view :att_license do
    "licensed under #{attribution_link license_text, license_url}"
  end

  private

  def attribution_link text, url
    "#{text} (#{url})"
  end

  def license_url
    "https://creativecommons.org/licenses/by/4.0"
  end

  def license_text
    "CC BY-SA 4.0"
  end
end
