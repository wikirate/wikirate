format :html do
  def with_header header, level: 3
    output [wrap_with("h#{level}", header), yield]
  end

  def standard_nest codename
    field_nest codename, view: :titled,
                         title: codename.cardname,
                         variant: "plural capitalized",
                         items: { view: :link }
  end

  view :menued do
    render_titled hide: [:title, :toggle], show: :menu
  end

  def tab_nest codename, args={}
    field_nest codename, args.reverse_merge(view: :menued, items: { view: :link })
  end

  def original_link url, opts={}
    text = opts.delete(:text) || "Visit Original"
    link_to text, opts.merge(path: url)
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
