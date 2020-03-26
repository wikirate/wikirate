include_set Abstract::Tabs

# mapping of all uniq values in each mapped column
#
# {
#   column1 => { val1 => card1.id,
#                val2 => card2.id,... },
#   column2 => { val3 => card3.id,... }, ...
# }
#
#

delegate :csv_file, :csv_row_class, to: :left

def followable?
  false
end

def history?
  false
end

event :update_import_mapping, :validate, on: :update, when: :mapping_param do
  merge_mapping(mapping)
  self.content = content_hash.to_json
end

def merge_mapping mapping
  mapping.each do |type, map_hash|
    content_hash[type].merge! map_hash
  end
end

def mapping
  return unless mp = mapping_param

  JSON.parse(mp).symbolize_keys
end

def mapping_param
  param[:mapping]
end

def generate!
  self.content = exact_match_map.to_json
end

def exact_match_map
  mapped_columns.each_with_object({}) do |column, map|
    map_type = map_type column
    type_map = map[map_type] = {}
    csv_file.each_row_hash do |row_hash|
      map_item row_hash[column], type_map, map_type
    end
  end
end

def csv_columns
  csv_row_class.columns
end

def map_type column
  csv_columns[column][:type] || column
end

def map_for_type type
  content_hash[type]
end

def map_item val, map, type
  return if val.strip.blank? || map.key?(key)
  custom_method = :"import_map_#{type}_val"
  map[val] =
    if left.respond_to? custom_method
      left.send custom_method, val
    else
      map_default_item val, type
    end
end

def map_default_item val, type
  card = Card[val]
  return unless card&.type_code == type

  card.id
end

def map_types
  @map_types = mapped_columns.map { |column| map_type column }.uniq
end

def content_hash
  @content_hash ||= JSON.parse(content).symbolize_keys
end

def mapped_columns
  csv_columns.keys.select do |key|
    csv_columns[key][:map]
  end
end

format :csv do
  view :export do
    raise Card::Error, "type required" unless (type = params[:map_type])

    lines = [["Name in File", "Name in WikiRate", "WikiRate ID"]]
    export_content_lines type, lines
    lines.map { |l| CSV.generate_line l }.join
  end

  def export_content_lines type, lines
    card.content_hash[type.to_sym].map do |key, value|
      lines << [key, value&.cardname, value]
    end
  end
end


format :html do
  view :core, template: :haml

  view :tabs, cache: :never do
    static_tabs tab_map
  end

  def item_view type
    item_view_hash[type] ||= begin
      method = "import_map_#{type}_view"
      fmt = card.left.format
      fmt.respond_to?(method) ? fmt.send(method) : :bar
    end
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
    map = card.content_hash[type]
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
