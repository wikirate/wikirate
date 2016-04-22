format :html do
  def fa_icon icon, opts={}
    <<-HTML
      <i class="fa fa-#{icon} #{opts[:class]}"></i>
    HTML
  end
end