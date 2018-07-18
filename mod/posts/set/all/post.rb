format :html do
  view :post_tab do
    output [field_nest(:post, items: { view: :thin_listing }),
            link_to("Add Post", path: { mark: :post,
                                        action: :new,
                                        "_#{card.type_name}": card.name },
                                class: "btn btn-primary")]
  end
end
