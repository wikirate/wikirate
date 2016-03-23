format :html do
  def fa_icon icon
    <<-HTML
      <i class="fa fa-#{icon}"></i>
    HTML
  end
end