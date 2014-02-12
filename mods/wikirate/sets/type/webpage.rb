
#event :clear_silly_name, :before=>:set_autoname do
#  self.name = ''
#end

event :autopopulate_website, :after=>:approve_subcards, :on=>:create do
  unless link_card = @subcards["+#{ Card[:wikirate_link].name }"]
    errors.add :link, 'valid uri required'
  end
  if errors[:link].empty?
    host = link_card.instance_variable_get '@host'

    website = Card[:wikirate_website].name    
    website_card = Card.new :name=>"+#{website}", :content => "[[#{host}]]", :supercard=>self
    website_card.approve

    @subcards["+#{website}"] = website_card
#    self.name = generate_name host
    
    if !Card.exists? host
      Card.create :name=>host, :type_id=>Card::WikirateWebsiteID
    end
  end
end

view :new do |args|
  _final_new args.merge( :core_edit=>true )
end

view :edit do |args|
  _final_edit args.merge( :core_edit=>true )
end

=begin
view :source_frame do |args|
  args[:st]
  output([
      link_to_page( "Source", card.name ),
      subformat( card.fetch :trait=>:wikirate_link ).render_content
      subformat(Card.fetch( "#{card.name}+source frame")).render_content
    
    ])
    
  }
end

=end
