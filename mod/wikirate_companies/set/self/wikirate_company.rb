include_set Abstract::CachedCount

recount_trigger :type, :wikirate_company, on: [:create, :delete] do |_changed_card|
  Card[:wikirate_company]
end

format :html do
  view :titled_content, template: :haml
end
