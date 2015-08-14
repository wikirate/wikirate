require 'rubygems'
require 'nokogiri'  
require 'open-uri'
require 'csv'
require File.expand_path('../../../config/environment',  __FILE__)


# get the companies aliases hash
# if the company exists in wikirate, import it

# Sebastian Jekutsch+CSR Report Available
# UN Global Compact+CSR Reporting Level
csr_report_available_metric = "Sebastian Jekutsch+CSR Report Available"
csr_report_level_metric = "UN Global Compact+CSR Reporting Level"

headers = %w{metric  company_name  year  value source}.compact
result = Hash.new
invalid_companies_source = Array.new

accepted_snippet_name = Hash.new

CSV.foreach(("script/metric/csv/accepted_metric_20150803.csv"),:encoding => 'windows-1251:utf-8',:headers => true, :header_converters => :symbol, :converters => :all) do |row|
  if row[:snippet_name] and row[:snippet_provider]
    accepted_snippet_name["#{row[:snippet_provider]}+#{row[:snippet_name]}"] = "#{row[:designer]}+#{row[:name]}"
  end
end
# some company snippets are not valid, checked manually
CSV.foreach(("script/metric/csv/validness_of_companies_for_unglobal.csv"),:headers => true, :header_converters => :symbol, :converters => :all) do |row|
  next if row[:remark] == nil || row[:remark] == "" || row[:remark] == "3" || row[:remark] == 3
  invalid_companies_source.push(row[:source_url])
end

Card::Auth.current_id = Card.fetch_id "Richard Mills"
Card::Auth.as_bot do

  def get_aliases_hash
    company_array = Array.new
    aliases_hash = Hash.new
    aliases_cards = Card.search :right=>"aliases",:left=>{:type_id=>Card::WikirateCompanyID}
    aliases_cards.each do |aliases_card|
      aliases_card.item_names.each do |name|
        aliases_hash[name.downcase] = aliases_card.cardname.left
      end
      company_array.push(aliases_card.cardname.left.downcase)
    end
    [aliases_hash,company_array]
  end





  file_name = "script/metric/import_fixed.json"

  text=File.open(file_name).read
  text.gsub!(/\r\n?/, "\n")


  begin
    aliases_hash, company_array = get_aliases_hash
    result_str = ""
    snippets_names = Array.new

    json_array = JSON.parse(text)

    json_array.each do |json_obj|
      company_name_in_wikirate = nil  
      snippets = json_obj["Snippets"][0]
      company = json_obj["Company_name"]
      aliases = json_obj["Aliases"]
      aliases.delete_if {|a| a.strip == company }
      
      snippets.each do |value|
        source_name = value["source_name"]
        name = value["name"]

        real_metric_name = accepted_snippet_name["#{source_name}+#{name}"]
        next if !real_metric_name && source_name != "UN Global Compact"
        # report name with "Grace" is not a real CSR 
        next if source_name == "UN Global Compact" && (value["details"] == nil || name.downcase.include?("grace") || !name.downcase.include?("report"))

        

        snipper_value = value["value"] ? value["value"].to_s.gsub("\"","\"\"") : ""
        snippet_source_link = value["source"]
        
        if !company_array.include?(company.downcase)
          aliases.each do |_alias|
            if _company = aliases_hash[_alias]
              company_name_in_wikirate = _company
              break
            end
          end
          next
        else
          company_name_in_wikirate = company
        end
        if company_name_in_wikirate != nil
          #%{metric  company_name  year  value source}.compact         
          if source_name == "UN Global Compact"
            details = value["details"]
            next if invalid_companies_source.include?(value["source"])
            level = value["source"].split("/")[-2]
            level = level.slice(0,1).capitalize + level.slice(1..-1)
            latest_year = details["Time period"][-4..-1]
            # if result.has_key?("\"#{csr_report_available_metric}\",\"#{_company}\",\"#{latest_year}\"")
            #   puts "#{"\"#{csr_report_available_metric}\",\"#{_company}\",\"#{latest_year}\""},#{result["\"#{csr_report_available_metric}\",\"#{_company}\",\"#{latest_year}\""]}"
            # end
            # if result.has_key?("\"#{csr_report_level_metric}\",\"#{_company}\",\"#{latest_year}\"")
            #   puts "#{"\"#{csr_report_level_metric}\",\"#{_company}\",\"#{latest_year}\""},#{result["\"#{csr_report_level_metric}\",\"#{_company}\",\"#{latest_year}\""]}"
            # end
            
            result["\"#{csr_report_available_metric}\",\"#{company_name_in_wikirate}\",\"#{latest_year}\""] = "\"Yes\",\"#{snipper_value}\""
            result["\"#{csr_report_level_metric}\",\"#{company_name_in_wikirate}\",\"#{latest_year}\""] = "\"#{level}\",\"#{snippet_source_link}\""
            # page = Nokogiri::HTML(open(value["source"]))   
            # company_name_from_page = page.css(".main-content-body").css("li")[0].text
            # puts "#{i},#{"\"#{_company}\""},\"#{value["source"]}\",\"#{company_name_from_page}\""
            
            # puts "#{"\"#{_company}\""},\"#{value["source"]}\",\"#{company_name_from_page}\""  
          else
            # normal case
            # snippets do not provide the citeyear for this metric but we can assume it is 2013
            if real_metric_name.start_with?("PERI")
              cite_year = "2013"
            else
              cite_year = value["citeyear"]
            end

            result["\"#{real_metric_name}\",\"#{company_name_in_wikirate}\",\"#{cite_year}\""] = "\"#{snipper_value}\",\"#{snippet_source_link}\""

          end
          
        end
       
      end
    end



    snippets_names = snippets_names.uniq
    puts result.length

    result_str = "#{headers.join(",")}\n"
    result.each do |key,value|
      # result_str+="#{key},#{array},#{result_count[key]},#{year_exist[key]}\n"
      result_str += "#{key},#{value}\n"
      # puts "\"#{metric_name}\",\"#{real_company_name}\",\"#{value["citeyear"]}\",\"#{_value}\",\"#{source_link}\""
    end
    File.open("script/metric/csv/metric_to_import_20150803.csv", 'w') { |file| file.write(result_str) }
  rescue RuntimeError=> bang
    raise "JSON parse error! #{bang}"
  end
end