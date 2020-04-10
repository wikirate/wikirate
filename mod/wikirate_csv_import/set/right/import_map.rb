include_set Abstract::Tabs

delegate :csv_file, to: :left
delegate :column_hash, :mapped_column_keys, :map_type, :map_types, to: :import_item_class
attr_writer :import_item_class

def followable?
  false
end

def history?
  false
end

# mapping of all uniq values in each mapped column (keys are strings)
# {
#   column1 => { val1 => card1.id,
#                val2 => card2.id,... },
#   column2 => { val3 => card3.id,... }, ...
# }
#
def map
  @map ||= content.present? ? parse_map(content) : {}
end

def parse_map map
  JSON.parse(map).symbolize_keys
end

def import_item_class
  @import_item_class ||= left.import_item_class
end

event :update_import_mapping, :validate, on: :update, when: :mapping_param do
  merge_mapping mapping_from_param
  self.content = map.to_json
end

def auto_map!
  @map ||= {}
  auto_map_items
  self.content = @map.to_json
end

format :csv do
  view :export do
    raise Card::Error, "type required" unless (type = params[:map_type])

    lines = [["Name in File", "Name in WikiRate", "WikiRate ID"]]
    export_content_lines type, lines
    lines.map { |l| CSV.generate_line l }.join
  end

  def export_content_lines type, lines
    card.map[type.to_sym].map do |key, value|
      lines << [key, value&.cardname, value]
    end
  end
end

private

def auto_map_items
  csv_file.each_row do |import_item|
    mapped_column_keys.each do |column|
      auto_map_item import_item, column
    end
  end
end

def auto_map_item import_item, column
  val = import_item[column]
  submap = @map[map_type(column)] ||= {}
  return if val.strip.blank? || submap.key?(val)

  submap[val] = import_item.map_field column
end

def merge_mapping mapping
  mapping.each do |column, submap|
    column = column.to_sym
    normalize_submap column, submap
    map[column].merge! submap
  end
end

def normalize_submap column, submap
  submap.each do |name_in_file, cardname|
    submap[name_in_file] = normalize_submap_item column, cardname
  end
end

def normalize_submap_item column, cardname
  return nil if cardname.blank?
  ii = import_item_class.new column => cardname
  if (card_id = ii.map_field column)
    card_id
  else
    errors.add :content, "invalid mapping: #{cardname}"
  end
end

def mapping_from_param
  mapping_param&.symbolize_keys
end

def mapping_param
  Env.params[:mapping]
end
