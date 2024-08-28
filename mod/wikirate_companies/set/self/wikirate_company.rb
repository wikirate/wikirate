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

  def os_type_param
    :wikirate_company
  end

  def filtered_headquarters
    @filtered_headquarters ||= params.dig :filter, :headquarters
  end

  def os_term_match
    super.tap do |bool|
      if filtered_headquarters.present?
        bool[:filter] = {
          "match_phrase_prefix": { "headquarters": filtered_headquarters }
        }
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
