card_accessor :reference, type: :search_type

format :html do
  def bar_menu_items
    super.insert 3, new_attribution_link(text: "Attribute")
  end

  def menu_items
    super.unshift attribution_link
  end

  def attribution_link text: ""
    modal_link "#{attribution_icon} #{text}",
               size: :large,
               path: { mark: card.reference_card, view: :link_and_list }
  end

  def new_attribution_link text: "", button: false
    modal_link "#{attribution_icon} #{text}",
               size: :large,
               class: ("btn btn-primary" if button),
               path: { mark: :reference,
                       action: :new,
                       card: { fields: { ":subject": card.name,
                                         ":party": Auth.current_card&.name } } }
  end

  def attribution_icon
    icon_tag :attribution
  end

  view :attributions do
    tabs "Rich Text" => { content: render_rich_text_attrib },
         "Plain Text" => { content:  render_plain_text_attrib },
         "HTML" => { content: render_html_attrib }
  end

  view :rich_text_attrib do
    "rich text attribution"
  end

  view :plain_text_attrib do
    "plain text attribution"
  end

  view :html_attrib do
    "html attribution"
  end
end
