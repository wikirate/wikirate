require File.expand_path('../../../config/environment',  __FILE__)

Card::Auth.current_id = Card.fetch_id "Richard Mills"
Card::Auth.as_bot do
  # change me if needed
  Card::Env[:protocol] = "http://"
  Card::Env[:host] = "wikirate.org"

  source_cache = Hash.new
  CSV.foreach(("script/metric/csv/metric_value_to_import.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
    
    metric_name = row[:metric]
    company_name = row[:company_name]
    year = row[:year]
    value = row[:value]
    source_url = row[:source]

    if metric_name != "EIC+EICC member" && metric_name != "Fairlabor+Fair Labor Participant"
      next
    else
      if metric_name == "EIC+EICC member"
        metric_name = "EICC+EICC member"
      else
        metric_name = "Fair Labor Association+Fair Labor Participant"
      end
      if !Card.exists? "#{metric_name}+#{company_name}+#{year}" 
        if !Card.exists?(company_name) || Card[company_name].type_id != Card::WikirateCompanyID
          puts "#{company_name} does not exist for #{metric_name}"
          next
        end
        if company_name.include?"/"
          puts "Company name with /:\t#{company_name}"
          next
        end
        subcard = {
          "+metric"=>{"content"=>metric_name},
          "+company"=>{"content"=>"[[#{company_name}]]",:type_id=>Card::PointerID},
          "+value"=>{"content"=>value.to_s.gsub("%",""), :type_id=>Card::PhraseID},
          "+year"=>{"content"=>year.to_s, :type_id=>Card::PointerID},
          "+source"=>{
            "subcards"=>{
              "new source"=>{
                "+Link"=>{
                  "content"=>source_url,
                   "type_id"=>Card::PhraseID
                }
              }
            }
          }
        }
        args = { :type_id=>Card::MetricValueID,:subcards=>subcard}
        puts "Metric Value Card created #{args}"
        Card.create! args
       
      else
        puts "duplicated snippets #{metric_name}+#{company_name}+#{year}"
      end
    end
  end
  
end
