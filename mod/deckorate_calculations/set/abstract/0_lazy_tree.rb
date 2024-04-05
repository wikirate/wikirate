format do
  def tree_item title, **args
    args.reverse_merge!(
      title: title,
      subheader: nil,
      data: nil,
      body: "",
      open: false,
      collapse_id: "card-#{card.name.safe_key}-#{args[:context]}-collapse-id"
    )
    haml :tree_item, **args
  end

  def stub_view view
    wrap_with :div,
              class: "card-slot card-slot-stub",
              data: { "stub-url": path(view: view) } do
      ""
    end
  end
end
