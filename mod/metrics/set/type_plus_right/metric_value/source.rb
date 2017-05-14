format :html do
  view :editor do
    return super() unless card.new?
    source = Card.new type_code: :source, name: "new source"
    subformat(source)._render_content_formgroup hide: "header help"
  end
end
