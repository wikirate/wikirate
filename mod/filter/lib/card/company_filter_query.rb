class Card
  class CompanyFilterQuery < FilterQuery
    def company_wql company
      name_wql company
    end
    alias wikirate_company_wql company_wql

    def topic_wql value
      add_to_wql :found_by, value.to_name.trait_name(:wikirate_company).trait(:refers_to)
    end
    alias wikirate_topic_wql topic_wql
  end
end
