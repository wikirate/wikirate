
format :html do
  view :thumbnail do |_args|
    wrap_with :div, class: 'metric-thumbnail' do
      _render_thumbnail_text
    end
  end

  view :thumbnail_text do
    wrap_with :div, class: 'thumbnail-text' do
      _render_thumbnail_title
    end
  end
  view :thumbnail_title do
    content = content_tag(:div, nest(card, view: :name),
                          class: 'ellipsis')
    card_link card, text: content, title: card.name
  end
end
