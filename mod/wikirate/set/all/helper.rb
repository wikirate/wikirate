format :html do
  def fa_icon icon, opts={}
    add_class opts, "fa fa-#{icon}"
    <<-HTML
      <i class="#{opts[:class]}"></i>
    HTML
  end
end
