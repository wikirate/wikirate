require File.expand_path('../../../config/environment',  __FILE__)
Card::Auth.as_bot
company_file = ARGV[0] || 'script/metric/csv/companies.txt'
def matched_company name
  if (company = Card.fetch(name)) && company.type_id == Card::WikirateCompanyID
    [name, :exact]
  elsif (result = Card.search :type=>'company', :name=>['match', name]) && !result.empty?
    [result.first.name, :partial]
  else
    Card.search(:type=>'company').each do |company|
      if name.match company.name
        return [company.name, :partial]
      end
    end
    ['', :none]
  end
end

File.open(company_file).each do |line|
  # byebug if line.include?"United Parcel Service"
  aliases = line.split("|")
  # company_name = aliases.shift
  is_partial = false
  is_exact = false
  partial_company_names = Array.new
  aliases.each do |al|
    if al.strip.length > 0
      wikirate_company, status = matched_company al
      if status == :exact
        puts "\"#{aliases.shift.gsub("\n","")}\",\"#{wikirate_company.gsub("\n","")}\",#{status},\"#{aliases.join(",").gsub("\n","")}\""      
        is_exact = true
        break
      elsif status == :partial
        is_partial = true
        partial_company_names.push wikirate_company
      end
    end
  end
  # byebug if line.include?"shell"
  puts "\"#{aliases.shift.gsub("\n","")}\",\"#{partial_company_names.uniq.join(",").gsub("\n","")}\",#{is_partial ? :partial : :none},\"#{aliases.join(",").gsub("\n","")}\"" if not is_exact
  
end

