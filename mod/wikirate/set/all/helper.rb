format :html do
  def fa_icon icon, opts={}
    prepend_class opts, "fa fa-#{icon}"
    %(<i class="#{opts[:class]}"></i>)
  end
end
