format :html do
  view :editor do |args|
    source = Card.new :type_code=>:source
    subformat(source)._render_content_formgroup(:hide=>'header help',:buttons=>"")
  end
end