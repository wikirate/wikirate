require 'link_thumbnailer'

=begin
view :core do |args|
  
#  site_card = Card["#{card.name.to_name.trunk_name}+Website"]
  #site = site_card && site_card.item_names.first
  link_to "source page", card.raw_content, :target=>'source', :class=>'wikirate-source-link external-link'
end
=end

view :editor do |args|
  form.text_field :content, :class=>'card-content',:placeholder=>"http://example.com"
end
event :validate_content, :before=>:approve, :on=>:save do
  begin
    @host = nil
    @host = URI(content).host
  rescue
  ensure
    errors.add :link, 'invalid uri' unless @host
  end
end
event :block_url_changing, :before=>:approve, :on=>:update do 
  if real? and db_content_changed?
    errors.add :link, "is not allowed to be changed."
  end
end
