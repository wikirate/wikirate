format :html do
  view :core, cache: :never do
    return super() unless card.descendant?
    with_paging do |paging_args|
      wrap_with :div, pointer_items(paging_args.extract!(:limit, :offset)),
                class: "pointer-list"
    end
  end

  view :closed_content do
    return super() unless descendant?
    item_view = implicit_item_view
    item_view = item_view == "name" ? "name" : "link"
    wrap_with :div, class: "pointer-list" do
      # unlikely that more than 100 items fit in closed content
      # even if every item is only one character
      pointer_items(view: item_view, limit: 100, offset: 0).join ", "
    end
  end

  def wrap_item rendered, item_view
    %(<div class="pointer-item item-#{item_view}">#{rendered}</div>)
  end
end

def item_names args={}
  raw_items(args[:content], args[:limit], args[:offset]).map do |item|
    polish_item item, args[:context]
  end
end

def raw_items content, limit, offset
  items = all_raw_items content
  limit = limit.to_i
  return items unless limit.positive?
  items[offset.to_i, limit] || []
end

def all_raw_items content=nil
  (content || self.content).to_s.split(/\n+/)
end

def polish_item item, context
  item = strip_item(item).to_name
  return item if context == :raw
  context ||= context_card.name
  item.absolute_name context
end

def strip_item item
  item.gsub(/\[\[|\]\]/, "").strip
end
