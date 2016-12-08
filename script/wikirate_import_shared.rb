
Card::Env[:protocol] = "http://"
Card::Env[:host] = "http://wikirate.org"
Card::Auth.current_id = Card.fetch_id "Richard Mills"

def potential_company name
  result = Card.search type: "company", name: ["match", name]
  return nil if result.empty?
  result
end

# @skip_list is an array storing company that are not matched by card names
# 1. try to match the aliases from the aliases_hash
# 2. if in the skipped list, return its name
# 3. try to find it by matching the name of existing companies
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

def write_array_to_file file_path, array
  File.open(file_path, "w") do |file|
    file.write(array.join("\n"))
  end
end

def silent_mode
  Card::Mailer.perform_deliveries = false
  yield
  Card::Mailer.perform_deliveries = true
end
