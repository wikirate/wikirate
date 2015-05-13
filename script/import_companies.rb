require File.expand_path('../../config/environment',  __FILE__)

Card::Auth.current_id = Card.fetch_id "Richard Mills"
Card::Auth.as_bot do
  company_to_wikirate_company = Hash.new
  CSV.foreach(("script/companies_in_wikirate.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
    if company_name = row[:company] and not company_name.include?"/" and ( not row.has_key? :accept_status or row[:accept_status] == 1 or row[:accept_status] == nil)
      company_to_wikirate_company[company_name] = row[:wikirate_company]
      _aliases = row[:aliases] || ""
      aliases = _aliases.split(",")
      aliases = aliases.collect{|x| x.strip}
      
      aliases.delete_if { |a| a.start_with?"com" and a.include?"/" or a.length<=3}
      

      alias_content = aliases.join("]]\n[[")
      alias_content = aliases.length > 0 ? "[[#{alias_content}]]" : ""
      if wikirate_company_name = row[:wikirate_company]
        aliases_card = Card.fetch("#{wikirate_company_name}+aliases") || Card.create!(:name=>"#{wikirate_company_name}+aliases",:type_id=>Card::PointerID)
        aliases_card.content = "#{alias_content}"
        
        puts "Aliases card:#{aliases_card.name} \talias:  #{alias_content}"
        aliases_card.save!
      elsif !Card.exists? row[:company]
        args = {:name=>row[:company],:type_id=>Card::WikirateCompanyID, :subcards=>{"+aliases"=>{:content=>"#{alias_content}",:type_id=>Card::PointerID}}}
        puts "Comapny Card created #{args}"
        Card.create! args
      end
    end
  end
end