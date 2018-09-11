def item_names args={}
  super args.merge(context: :raw)
end

format :html do
  def default_item_view
    :name
  end
end