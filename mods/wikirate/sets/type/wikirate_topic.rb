view :missing do |args|
  _render_link args
end
view :image do |args|
  #byebug
  image_card = Card.fetch("#{ card.name }+image")
  image_source_card = Card.fetch("#{ card.name }+image source")
  image_url = ""
  if image_card
    image_url = image_card.format( :format=>:html)._render(:source) 
  end
  title = ""
  if image_source_card
    title = strip_tags image_source_card.content
  end
  %{<img src='#{image_url}' title='#{title}' />}

end