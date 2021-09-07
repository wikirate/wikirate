format :html do
  def original_link url, opts={}
    text = opts.delete(:text) || "Visit Original"
    link_to text, opts.merge(path: url)
  end

  view :menued do
    render_titled hide: [:title, :toggle], show: :menu
  end

  view :type_link, template: :haml do
    @type_card = card.type_card
  end

  def type_link_label
    @type_card.name
  end

  def type_link_icon
    mapped_icon_tag @type_card.codename
  end
end
