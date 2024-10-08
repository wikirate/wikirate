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
end
