require File.expand_path('../../../config/environment',  __FILE__)
require 'colorize'
require 'json'
require 'byebug'
require 'rubygems'
require 'csv'

file_name = 'script/metric/data/certh.json'

text = File.open(file_name).read

def generate_aliases_hash
  aliases_hash = {}
  aliases_cards = Card.search right: 'aliases',
                              left: { type_id: Card::WikirateCompanyID }
  aliases_cards.each do |aliases_card|
    aliases_card.item_names.each do |name|
      aliases_hash[name.downcase] = aliases_card.cardname.left
    end
  end
  aliases_hash
end

def potential_company name
  result = Card.search type: 'company', name: ['match', name]
  return nil if result.empty?
  result
end

def company_skip_list
  %w(BROO Off ACE SAS WPS)
end

def correct_company_name company, aliases, aliases_hash, skip_list
  return company if Card.exists?(company)
  aliases.each do |al|
    if (found_company = aliases_hash[al.downcase])
      return found_company
    end
  end
  return company if skip_list.include?(company)
  if (potential_com = potential_company(company))
    return potential_com.map(&:name)[0]
  end
  company
end

begin

  aliases_hash = generate_aliases_hash
  skip_list = company_skip_list

  result = []

  json_array = JSON.parse(text)
  json_array.each do |json_obj|
    snippets = json_obj['Snippets'][0]
    company = json_obj['Company_name']
    aliases = json_obj['Aliases']
    snippets.each do |value|
      next if value['name'] != 'Conflict Minerals Report'
      cite_year = value['citeyear']
      url = value['value']

      # final_company = nil
      # company_not_found = true



      correct_name =
        correct_company_name company, aliases, aliases_hash, skip_list

      result.push "\"#{url}\",\"#{correct_name}\",\"#{cite_year}\","\
                    '"Conflict Minerals Report"'
      # if !Card.exists?(company)
      #   # puts company
      #   aliases.each do |al|
      #     next unless (found_company = aliases_hash[al.downcase])
      #     final_company = found_company
      #     company_not_found = false
      #     break
      #   end
      #   if company_not_found
      #     next if skip_list.include?(company)
      #     if (potential_com = potential_company(company))
      #       final_company = potential_com.map(&:name)[0]
      #     end
      #   end
      # else
      #   puts "found: #{company},#{company},#{url},#{cite_year}".green
      #   result.push "\"#{url}\",\"#{company}\",\"#{cite_year}\","\
      #               '"Conflict Minerals Report"'
      #   next
      # end
      # if !final_company
      #   puts "#{company} not found in wikirate.".yellow
      #   result.push "\"#{url}\",\"#{company}\",\"#{cite_year}\","\
      #               '"Conflict Minerals Report"'
      # elsif company_not_found
      #   puts "potential found: #{company},#{final_company},#{url}"\
      #        ",#{cite_year}".light_blue
      #   result.push "\"#{url}\",\"#{final_company}\",\"#{cite_year}\","\
      #               '"Conflict Minerals Report"'
      # else
      #   puts "found: #{company},#{final_company},#{url},#{cite_year}".green
      #   result.push "\"#{url}\",\"#{final_company}\",\"#{cite_year}\","\
      #               '"Conflict Minerals Report"'
      # end
    end
  end
  File.open('script/metric/data/sources.csv', 'w') do |file|
    file.write(result.join("\n"))
  end
rescue => error
  puts error.message.to_s.red
end
