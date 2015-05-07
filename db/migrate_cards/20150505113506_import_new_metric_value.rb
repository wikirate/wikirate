# -*- encoding : utf-8 -*-

class ImportNewMetricValue < Card::Migration
  def up
    Card::Auth.current_id = Card.fetch_id "Richard Mills"
    Card::Auth.as_bot do
      Card.create! :name=>"Company+aliases+*type plus right+*default",:type_id=>Card::PointerID if !Card["Company+aliases+*type plus right+*default"]
      Card["JP Morgan Chase"].delete! if Card.exists?"JP Morgan Chase"
      accepted_snippet_name = Hash.new
      
      company_to_wikirate_company = Hash.new
      wikirate_company_to_aliases = Hash.new
      # CSV.foreach(data_path("first_metrics_to_import.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
      #   if row[:snippet_name] and row[:snippet_provider]
      #     accepted_snippet_name["#{row[:snippet_provider]}+#{row[:snippet_name]}"] = "#{row[:designer]}+#{row[:name]}"
      #   end
      # end
      accepted_snippet_name["Newsweek+Newsweek Green Score"] = "Newsweek+Newsweek Green Score"
      CSV.foreach(data_path("companies_in_wikirate.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
        if company_name = row[:company] and not company_name.include?"/" and ( not row.has_key? :accept_status or row[:accept_status] == 1 or row[:accept_status] == nil)
          company_to_wikirate_company[company_name] = row[:wikirate_company]
          _aliases = row[:aliases] || ""
          aliases = _aliases.split(",")
          aliases.delete_if { |a| a.start_with?"com" and a.include?"/" or a.length<=3}
          wikirate_company_to_aliases[row[:company]] = aliases 
        end
      end

      json_array = Array.new
      text=File.open(data_path("certh_snippets.txt")).read
      text.gsub!(/\r\n?/, "\n")
      _json = ""
      text.each_line do |line|
        if line.start_with?("{")
          _json = ""
        end
        if line.start_with?("}") 
          _json+="}"
          json_array.push _json
        else
          _json+=line
        end
      end
      source_cache = Hash.new
      json_array.each do |json|
        json_obj = JSON.parse(json)
        snippets = json_obj["Snippets"][0]
        company = json_obj["Company_name"]
        content = ""
        next if  snippets == nil
        if wikirate_company_to_aliases.has_key?company
          wikirate_company_to_aliases[company].each do |al|
            content+="[[#{al}]]\n"
          end
        end
        company_name = company
        if wikirate_company = company_to_wikirate_company[company]
          # update aliases
          aliases_card = Card.fetch("#{wikirate_company}+aliases") || Card.create!(:name=>"#{wikirate_company}+aliases")
          aliases_card.content = content
          aliases_card.save!
          company_name = wikirate_company
          puts "Aliases card:#{aliases_card.name} \t#{content}"
        else 
          # create company
          if not company.include?"/"
            any_accepted_snipprt = false
            snippets.each do |value|
              source_name = value["source_name"]
              name = value["name"]
              if accepted_snippet_name.has_key?"#{source_name}+#{name}" and value.has_key?"citeyear"
                any_accepted_snipprt = true
                break
              end
            end
            if any_accepted_snipprt
              a = {:name=>company,:type_id=>Card::WikirateCompanyID, :subcards=>{"+aliases"=>{:content=>content}}}
              puts "Card created #{a}"
              if existing_card = Card[company]
                company_name = existing_card.name
              else
                Card.create! :name=>company,:type_id=>Card::WikirateCompanyID, :subcards=>{"+aliases"=>{:content=>content}}
                company_to_wikirate_company[company] = company
              end
            end
          end
        end
        
        snippets.each do |value|
          name = value["name"]
          _value = value["value"]
          source_name = value["source_name"]
          source_link = value["source"]

          if accepted_snippet_name.has_key?"#{source_name}+#{name}" and value.has_key?"citeyear"
            
            # create metric value
            metric_name = accepted_snippet_name["#{source_name}+#{name}"]
            if !Card.exists? "#{metric_name}+#{company_name}+#{value["citeyear"]}"
               a = { :name=>"#{metric_name}+#{company_name}+#{value["citeyear"]}",:type_id=>Card::MetricValueID,:subcards=>{'+value'=>{:content=>value["value"].to_s}}}
              puts "Card created #{a}"
              Card.create! :name=>"#{metric_name}+#{company_name}+#{value["citeyear"]}",:type_id=>Card::MetricValueID,:subcards=>{'+value'=>{:content=>value["value"].to_s}}
             
              sourcepage = source_cache[value["source"]]
              if sourcepage == nil
                Card::Env.params[:sourcebox] = 'true'
                a = { :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> value["source"]}} }
                puts "Card created #{a}"
                sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> value["source"]}} 
                source_cache[value["source"]] = sourcepage
              end
              a = { :name=>"#{metric_name}+#{company_name}+#{value["citeyear"]}+source",:type_id=>Card::PointerID,:content=>"[[#{sourcepage.name}]]\n"  }
              puts "Card created #{a}"
              Card.create! :name=>"#{metric_name}+#{company_name}+#{value["citeyear"]}+source",:type_id=>Card::PointerID,:content=>"[[#{sourcepage.name}]]\n"
            else
              puts "duplicated snippets #{metric_name}+#{company_name}+#{value["citeyear"]}"
            end
           
          end
        end
      end
    end
    # raise "hjello"
  end
end
