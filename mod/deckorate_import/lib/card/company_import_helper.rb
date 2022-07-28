class Card
  # helper for import item classes that include a company field
  module CompanyImportHelper
    def wikirate_company_suggestion_filter name, import_manager
      hq = headquarters_in_file name.to_name, import_manager
      puts "hq for #{name}: #{hq}"
      { name: name, headquarters: hq }
    end

    def headquarters_in_file name, import_manager
      import_manager.each_item do |_index, item|
        next unless item[:wikirate_company].to_name == name

        hq = item[:headquarters]
        return hq if hq.present?
      end
      nil
    end
  end
end