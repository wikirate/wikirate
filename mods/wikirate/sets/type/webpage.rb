require 'link_thumbnailer'

#event :clear_silly_name, :before=>:set_autoname do
#  self.name = ''
#end
event :grab_fields_from_url,  :before=>:process_subcards, :on=>:create do
  
  unless link_card = subcards["+#{ Card[:wikirate_link].name }"]
    errors.add :link, 'valid uri required'
  end

  url = link_card["content"]
  preview = LinkThumbnailer.generate(url)
  first_image_url = ""
  if preview.images.length >0
    first_image_url = preview.images.first.src.to_s
  end

  subcards["+title"] ={'content'=> "#{preview.title}"}
  subcards["+description"] = {'content'=> "#{preview.description}"}
  subcards["+image url"] ={'content'=> "#{first_image_url}" }


end
event :autopopulate_website, :after=>:approve_subcards, :on=>:create do


  if errors[:link].empty?
    link_card = subcards["+#{ Card[:wikirate_link].name }"]
    host = link_card.instance_variable_get '@host'

    website = Card[:wikirate_website].name    
    website_card = Card.new :name=>"+#{website}", :content => "[[#{host}]]", :supercard=>self
    website_card.approve

    subcards["+#{website}"] = website_card
#    self.name = generate_name host
    
    if !Card.exists? host
      Card.create :name=>host, :type_id=>Card::WikirateWebsiteID
    end
  end
end

view :new do |args|
  super args.merge( :core_edit=>true, :structure=>:quick_page )
end

view :edit do |args|
  super args.merge( :core_edit=>true )
end

view :content do |args|
  add_name_context
  super args
end

view :missing do |args|
  _view_link args
end
