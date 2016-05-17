format :html do
  view :editor do |args|
    if card.new?
      source = Card.new type_code: :source, name: "new source"
      subformat(source)._render_content_formgroup(hide: "header help",
                                                  buttons: ""
                                                 )
    else
      super args
    end
  end
end
