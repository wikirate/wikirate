require File.expand_path('../../../config/environment',  __FILE__)
Card::Env[:protocol] = "http://"
Card::Env[:host] = "http://wikirate.org"
Card::Auth.current_id = Card.fetch_id "Richard Mills"
Card::Auth.as_bot do
  source_cache = Hash.new
  CSV.foreach(("script/metric/csv/metric_to_import_20150803.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
    
    metric_name = row[:metric]
    company_name = row[:company_name]
    year = row[:year]
    value = row[:value]
    source_url = row[:source]

    if !Card.exists? "#{metric_name}+#{company_name}+#{year}" 
      if company_name.include?"/"
        puts "Company name with /:\t#{company_name}"
        next
      end
      
      sources = Array.new
      if source_url.start_with?("[")
        begin
          sources = JSON.parse(source_url)
          source_url = sources[0]
          sources = sources[1..-1]
        rescue JSON::ParserError => e
          puts "fail to parse json"
        end
      end
      if metric_name=="Sebastian Jekutsch+CSR Report Available"
        binding.pry
      else
        next

      end

      subcard = {
        "+metric"=>{"content"=>metric_name},
        "+company"=>{"content"=>"[[#{company_name}]]",:type_id=>Card::PointerID},
        "+value"=>{"content"=>value.to_s, :type_id=>Card::PhraseID},
        "+year"=>{"content"=>year.to_s, :type_id=>Card::PointerID},
        "+Link"=>{:content=>source_url, "type_id"=>Card::PhraseID}
      }
      
      metric_value = Card.new :type_id=>Card::MetricValueID,:subcards=>subcard
      if metric_value.errors.empty?
        puts "metric value card to be created #{subcard}"
        metric_value.save!
      else
        puts metric_value.errors
        next
      end
      # add sources to +source pointer
      metric_value_source_card = metric_value.fetch(:trait=>:source)
      source_cache[source_url] = metric_value_source_card.item_cards[0]
      sources_to_be_added_to_plus_source = Array.new
      if sources != nil
        sources.each do |source|
          sourcepage = source_cache[source]
          if sourcepage == nil
            Card::Env.params[:sourcebox] = 'true'
            args = { :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> source}} }
            puts "Source Card created #{args}"
            sourcepage = Card.create! args
            source_cache[source] = sourcepage
          end
          sources_to_be_added_to_plus_source.push(sourcepage.name)
        end
        sources_to_be_added_to_plus_source.each do |source|
          metric_value_source_card<<source
        end
        metric_value_source_card.save!
        
      end

    else
      puts "duplicated snippets #{metric_name}+#{company_name}+#{year}"
    end
  end
  
end