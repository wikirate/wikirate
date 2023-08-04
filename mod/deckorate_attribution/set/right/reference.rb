include_set Abstract::VirtualSearch,
            cql_content: { type: :reference, right_plus: [:subject, refer_to: "_left"] }

format :html do
  view :link_and_list, template: :haml
end
