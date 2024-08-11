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

  # TODO: move to a more general accessible place (or its own abstract module)
  def card_stub path_args
    wrap_with :div,
              class: "card-slot card-slot-stub",
              data: { "stub-url": path(path_args) } do
      ""
    end
  end
end
