card_accessor :reference, type: :search_type

def attribution_authors
  [creator.name]
end

def attribution_title
  name
end

format do
  delegate :attribution_title, :attribution_authors, to: :card

  view :att_wikirate do
    "Wikirate.org"
  end

  view :att_title do
    "'#{attribution_title}' (#{render_id_url}) by #{render_attribution_authorship}"
  end

  view :attribution_authorship do
    attribution_authors.to_sentence
  end

  view :att_license do
    "licensed under #{license_text} (#{license_url})"
  end

  private

  def license_url
    "https://creativecommons.org/licenses/by/4.0"
  end

  def license_text
    "CC BY-SA 4.0"
  end
end

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

  view :att_wikirate do
    link_to "Wikirate.org", href: "https://wikirate.org", target: "_blank"
  end

  view :att_title do
    "'#{link_to attribution_title, href: render_id_url}' " \
      "by #{render_attribution_authorship}"
  end

  view :attribution_authorship do
    attribution_authors.map do |author_name|
      if (author_id = author_name.card_id)
        link_to author_name, href: card_url("~#{author_id}")
      else
        author_name
      end
    end.to_sentence
  end

  view :att_license do
    "licensed under #{link_to license_text, href: license_url}"
  end
end

