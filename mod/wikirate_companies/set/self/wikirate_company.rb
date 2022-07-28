include_set Abstract::CachedCount
include_set Abstract::CompanySearch

recount_trigger :type, :wikirate_company, on: [:create, :delete] do |_changed_card|
  Card[:wikirate_company]
end

format :html do
  include Card::CompanyImportHelper

  before(:filtered_content) { voo.items[:view] = :box }

  # override to use opensearch
  view :compact_filtered_content, template: :haml, wrap: :slot

  def import_suggestions_search

    puts "company filter params: #{params[:filter]}"

    open_search_with_params
  end

  def open_search_with_params
    search_with_params
  end
end
