# -*- encoding : utf-8 -*-

class ImportNewCompany < Card::Migration
  def up
    company_to_wikirate_company = Hash.new
    CSV.foreach(data_path("companies_in_wikirate.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
      if company_name = row[:company] and not company_name.include?"/" and ( not row.has_key? :accept_status or row[:accept_status] == 1 or row[:accept_status] == nil)
        company_to_wikirate_company[company_name] = row[:wikirate_company]
        _aliases = row[:aliases] || ""
        aliases = _aliases.split(",")
        aliases = aliases.collect{|x| x.strip}
        
        aliases.delete_if { |a| a.start_with?"com" and a.include?"/" or a.length<=3}
        

        alias_content = aliases.join("]]\n[[")
        if wikirate_company_name = row[:wikirate_company]
          aliases_card = Card.fetch("#{wikirate_company_name}+aliases") || Card.create!(:name=>"#{wikirate_company_name}+aliases")
          aliases_card.content = "[[#{alias_content}]]"
          aliases_card.save!
          puts "Aliases card:#{aliases_card.name} \t#{alias_content}"
        elsif !Card.exists? row[:company]
          args = {:name=>row[:company],:type_id=>Card::WikirateCompanyID, :subcards=>{"+aliases"=>{:content=>"[[#{alias_content}]]"}}}
          puts "Comapny Card created #{args}"
          Card.create! args
        end
      end
    end
    # raise "hello"
  end
end
