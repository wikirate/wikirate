include_set Abstract::Tabs

delegate :csv_file, to: :left
delegate :column_hash, :mapped_column_keys, :map_type, to: :import_item_class
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
  @map ||= content.present? ? JSON.parse(content).symbolize_keys : {}
end

def import_item_class
  @import_item_class ||= left.import_item_class
end

event :update_import_mapping, :validate, on: :update, when: :mapping_param do
  merge_mapping mapping_from_param
  self.content = map.to_json
end

def generate!
  self.content = exact_match_map.to_json
end

def exact_match_map
  csv_file.each_row do |import_item|
    mapped_column_keys.each do |column|
      map_item import_item, column
    end
  end
end

def map_item import_item, column
  val = import_item[column]
  submap = map[map_type(column)] ||= {}
  return if val.strip.blank? || submap.key?(val)

  submap[val] = import_item.map_field column
end

def map_default_item val, type
  card = Card[val]
  return unless card&.type_code == type

  card.id
end

def map_types
  @map_types = mapped_column_keys.map { |column| map_type column }.uniq
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

def merge_mapping mapping
  mapping.each do |type, map_hash|
    map[type].merge! map_hash
  end
end

def mapping_from_param
  return unless mp = mapping_param

  JSON.parse(mp).symbolize_keys
end

def mapping_param
  param[:mapping]
end
