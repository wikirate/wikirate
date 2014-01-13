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
    errors.add :link, "source uri already in use.  see #{Card::Format.new( duplicates.first ).render_link}"
  end
end