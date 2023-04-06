class Card
  # helper for import item classes that include a company field
  module CompanyImportHelper
    def wikirate_company_suggestion_filter name, import_manager
      hq = headquarters_in_file name.to_name, import_manager
      { name: name, headquarters: hq }
    end

    private

    def headquarters_in_file name, import_manager
      import_manager.each_item do |_index, item|
        hq = item[:headquarters]
        return hq if hq.present? && item[:wikirate_company].to_name == name
      end
      nil
    end
  end
end
