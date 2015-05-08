# -*- encoding : utf-8 -*-

class ImportNewMetricValue < Card::Migration
  def up
    Card::Auth.current_id = Card.fetch_id "Richard Mills"
    Card::Auth.as_bot do
     
      CSV.foreach(data_path("metric_value_to_import.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
        
        metric_name = row[:metric]
        company_name = row[:company_name]
        year = row[:year]
        value = row[:value]
        source_url = row[:source]
        if !Card.exists? "#{metric_name}+#{company_name}+#{year}"
          args = { :name=>"#{metric_name}+#{company_name}+#{year}",:type_id=>Card::MetricValueID,:subcards=>{'+value'=>{:content=>value.to_s.gsub("%","")}}}
          puts "Metric Value Card created #{args}"
          # Card.create! args
         
          sourcepage = source_cache[value["source"]]
          if sourcepage == nil
            Card::Env.params[:sourcebox] = 'true'
            args = { :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> source_url}} }
            puts "Source Card created #{args}"
            sourcepage = Card.create! args
            source_cache[value["source"]] = sourcepage
          end
          args = { :name=>"#{metric_name}+#{company_name}+#{year}+source",:type_id=>Card::PointerID,:content=>"[[#{sourcepage.name}]]\n"  }
          puts "Metric Source Card created #{args}"
          # Card.create! args
        else
          puts "duplicated snippets #{metric_name}+#{company_name}+#{year}"
        end
      end
      
    end
  end
end
