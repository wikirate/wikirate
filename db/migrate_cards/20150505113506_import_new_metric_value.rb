# -*- encoding : utf-8 -*-

class ImportNewMetricValue < Card::Migration
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
  def up
    wikirate_company, status = matched_company(file_company)
    
  end
end
