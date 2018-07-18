format :html do
  view :editor do
    options_card ||= Card::Name[:wikirate_company, :type, :by_name]
    text_field :content,
               class: "wikirate_company_autocomplete form-control",
               "data-options-card": options_card,
               placeholder: "Company"
  end
end
