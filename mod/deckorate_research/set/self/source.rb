include_set Abstract::SourceSearch
include_set Abstract::CachedCount

recount_trigger :type, :source, on: [:create, :delete] do |_changed_card|
  Card[:source]
end

format :html do
  view :copy_catcher, unknown: true, wrap: :slot, cache: :never do
    url = params[:url]
    return "" unless url && (sources = Card::Source.search_by_url url)&.any?

    haml :copy_catcher, sources: sources
  end
end
