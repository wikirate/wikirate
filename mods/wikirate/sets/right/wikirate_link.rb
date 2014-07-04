
view :core do |args|
  
  site_card = Card["#{card.name.to_name.trunk_name}+Website"]
  #site = site_card && site_card.item_names.first
  link_to "source page", card.raw_content, :target=>'source', :class=>'wikirate-source-link external-link'
end

event :validate_content, :before=>:approve, :on=>:save do
  begin
    @host = nil
    @host = URI(content).host
  rescue
  ensure
    errors.add :link, 'invalid uri' unless @host
  end
  
  
  #need to check if content changed...
  duplicate_wql = { :right=>cardname.tag, :content=>content }
  duplicate_wql[:not] = { :id => id } if id
  duplicates = Card.search duplicate_wql
  if duplicates.any?
    if Card::Env.params[:quickframe]
      supercard.name = duplicates.first.cardname.left
      abort :triumph
    else
      errors.add :link, "source uri already in use.  see #{Card::Format.new( duplicates.first ).render_link}"
    end
  end
end


view :iframe do |args|
#  return 'iframe' if Rails.env.development?
#  subformat( Card.fetch( "#{card.cardname.left}+source frame" ) ).render_content
  %{<iframe sandbox="allow-same-origin allow-scripts allow-popups allow-forms" src="#{_render_raw}"></iframe>}
end

view :edit_in_form do |args|
  if !card.content.blank? and card.left and card.left.type_id == Card::WebpageID
    view = args[:home_view] || :core
    render view, args
  else
    super args
  end
end

