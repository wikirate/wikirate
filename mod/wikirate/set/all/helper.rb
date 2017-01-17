format :html do
  def with_header header
    output [wrap_with(:h2, header), yield]
  end

  def fa_icon icon, opts={}
    prepend_class opts, "fa fa-#{icon}"
    %(<i class="#{opts[:class]}"></i>)
  end

  def standard_pointer_nest codename
    field_nest codename, view: :titled,
                         cache: :never,
                         title: codename.cardname.s,
                         variant: "plural capitalized",
                         items: { view: :link }
  end
end
