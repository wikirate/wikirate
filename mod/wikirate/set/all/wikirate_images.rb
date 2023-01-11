format :html do
  def svg_icon_tag icon, _opts={}
    image_tag "/mod/wikirate/icons/#{icon}.svg"
  end
end
