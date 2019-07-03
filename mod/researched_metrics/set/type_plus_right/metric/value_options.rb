include_set Abstract::MetricChild, generation: 1
include_set Abstract::DesignerPermissions

def item_names args={}
  super args.merge(context: :raw)
end

def options_hash
  json_options? ? parse_content : option_hash_from_names
end

def json_options?
  type_id == Card::JsonID
end

def option_hash_from_names
  item_names.each_with_object({}) { |name, hash| hash[name] = name }
end

format :html do
  def default_item_view
    :name
  end
end
