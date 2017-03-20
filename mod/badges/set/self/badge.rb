include_set Abstract::Table

format :html do
  view :core do
    wikirate_table :plain, Card.fetch("badges+*type+by name").format(format: :html).search_with_params,
                   [:name_with_certificate, :description, :awarded]
  end
end
