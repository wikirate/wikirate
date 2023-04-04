include_set Abstract::CachedCount
include_set Abstract::CompanySearch
include_set Abstract::OpenSearch

recount_trigger :type, :wikirate_company, on: [:create, :delete] do |_changed_card|
  Card[:wikirate_company]
end

format do
  include Card::CompanyImportHelper

  def os_search_index
    "companies"
  end

  def filtered_name
    @filtered_name ||= params.dig :filter, :name
  end

  def filtered_headquarters
    @filtered_headquarters ||= params.dig :filter, :headquarters
  end

  def os_term_match
    bool = yield
    bool[:minimum_should_match] =  1
    os_company_name_match bool if filtered_name.present?
    os_hq_match bool if filtered_headquarters.present?
  end

  def os_company_name_match bool
    bool[:should] = [{ match: { name: filtered_name } },
                     { match_phrase_prefix: { name: filtered_name } }]
  end

  def os_hq_match bool
    bool[:filter] = { "match_phrase_prefix": { "headquarters": filtered_headquarters } }
  end

  def all_regions
    Card.search type: :region, limit: 0, return: :name, sort: :name
  end

  def os_search_returning_cards
    super.tap do |cardlist|
      if (exact_match = filtered_name&.card) &&
         (!cardlist.include?(exact_match)) &&
         (exact_match.type_code == :wikirate_company)
        cardlist.unshift exact_match
      end
    end
  end
end

format :html do
  before(:filtered_content) { voo.items[:view] = :box }

  # override to use opensearch
  view :compact_filtered_content, template: :haml, wrap: :slot, cache: :never

  def headquarters_options
    options_for_select [["--", ""]] + all_regions, params.dig(:filter, :headquarters)
  end

  def import_suggestions_search
    os_search_returning_cards
  end
end
