
format :html do
  view :core, template: :haml

  view :tabs, cache: :never do
    static_tabs tab_map
  end

  def item_view type
    item_view_hash[type] ||= card.left.try("import_map_#{type}_view") || :bar
  end

  def item_view_hash
    @item_view_hash ||= {}
  end

  def tab_map
    card.map_types.each_with_object({}) do |type, tab|
      tab[type] = { content: map_table(type), title: tab_title(type) }
      tab
    end
  end

  def map_table type
    haml :map_table, map_type: type
  end

  def tab_title type
    map = card.map[type]
    total = map.keys.count
    unmapped = total - map.values.compact.count
    title = type.cardname.vary :plural
    title = "(#{unmapped}) #{title}" if unmapped.positive?
    wrapped_tab_title title, total_badge(type, total)
  end

  def total_badge type, count
    tab_badge count, mapped_icon_tag(type), klass: "RIGHT-#{type.cardname.key}"
  end

  def export_link type
    link_to_card card, "csv", path: { format: :csv, view: :export, map_type: type }
  end

  def map_ui type
    haml :map_ui, type: type
  end
end
