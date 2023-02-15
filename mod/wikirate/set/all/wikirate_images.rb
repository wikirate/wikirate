format :html do
  def wikirate_icon_tag icon, _opts={}
    %(<i class="wr-icon wr-icon-#{icon}"></i>)
  end
end
