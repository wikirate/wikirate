format :html do
  def with_header header
    output [wrap_with(:h3, header), yield]
  end

  def icon_tag type, opts={}
    lib = opts.delete(:library) || :fa
    prepend_class opts, "#{lib} #{lib}-#{type}"
    %(<i #{tag_options opts}></i>)
  end

  def fa_icon type, opts={}
    icon_tag type, opts
  end

  def standard_pointer_nest codename
    field_nest codename, view: :titled,
                         cache: :never,
                         title: codename.cardname.s,
                         variant: "plural capitalized",
                         items: { view: :link }
  end

  def original_link url, text = "Visit Original"
    link_to text, path: url
  end
end
