include_set Abstract::Media

format :html do
  view :rich_header, cache: :never, template: :haml do
    voo.size ||= :xlarge
  end

  view :header_left do
    voo.size ||= :large
    header_left
  end

  view :header_middle, template: :haml

  view :header_right do
    ""
  end

  def header_left
    text_with_image title: header_title, text: header_text
  end

  def header_title
    render_title_link
  end

  def header_text
    ""
  end

  def header_middle_items
    {
      "WikiRate ID": link_to(card.id, href: "/~#{card.id}")
    }
  end

  view :shared_header do
    header_left
  end
end
