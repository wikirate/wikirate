=begin
def autoname ignore=nil
  size_limit = 80

  title, date = %w{ Title Date }.map do |field|
    value = if cards.blank?
        #currently only for migrations
        c = Card["#{self.name}+#{field}"] and c.content
      else
        fld = cards[ "+#{field}" ] and fld["content"]
      end
    if value.blank?
      errors.add :autoname, "need valid #{field}"
      value = nil
    else
      unwanted_characters_regexp = %{[#{(Card::Name.banned_array + %w{ [ ] n }).join('\\')}/]}
      value.gsub! /#{unwanted_characters_regexp}/, ''
      if past_size_limit = value[size_limit+1] and past_size_limit =~ /^\S/
        value = value[0..size_limit].gsub /\s+\S*$/, '...'
      end
    end
    value
  end
  "#{title} - #{date}"
end
=end        


event :clear_silly_name, :before=>:set_autoname do
  self.name = ''
end

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

#def generate_name host, i=1
#  #FIXME - very slow way to do this!!
#  name = "#{host}-#{i}"
#  if Card.exists? name
#    generate_name host, i+1
#  else
#    name
#  end
#end

view :new do |args|
  _final_new args.merge( :hidden=>{:success=>{ :redirect=>true, :id=>'_self', :view=>'edit', :layout=>'split_screen' } } )
end

view :edit do |args|
  if Wagn::Env.params[:layout] == 'split_screen'
    args.merge! :hidden=>{:success=>{:redirect=>true}}
  end
  _final_edit args
end


