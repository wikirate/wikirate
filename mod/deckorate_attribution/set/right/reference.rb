include_set Abstract::ListRefCachedCount,
            type_to_count: :reference,
            list_field: :subject

format :html do
  view :link_and_list, template: :haml
end
