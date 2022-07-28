include_set Abstract::CachedCount
include_set Abstract::CompanySearch
include_set Abstract::OpenSearch

recount_trigger :type, :wikirate_company, on: [:create, :delete] do |_changed_card|
  Card[:wikirate_company]
end

format :html do
  include Card::CompanyImportHelper

  before(:filtered_content) { voo.items[:view] = :box }

  # override to use opensearch
  view :compact_filtered_content, template: :haml, wrap: :slot

  def os_search_index
    "companies"
  end

  def import_suggestions_search
    os_search_returning_cards
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

  def headquarters_options
    options_for_select [["--", ""]] + all_regions, params.dig(:filter, :headquarters)
  end

  def all_regions
    Card.search type: :region, limit: 0, return: :name, sort: :name
  end
end
