include_set Abstract::MetricChild, generation: 1
include_set Abstract::DesignerPermissions
include_set Abstract::Filterable

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

  view :core do
    filtering(".RIGHT-answer ._filter-widget") do
      super()
    end
  end

  def wrap_item rendered, item_view
    return super unless item_view == :name

    wrap_with :div, rendered,
              class: "pointer-item item-#{item_view} _filterable",
              data: { filter: { status: :exists, year: :latest, value: rendered } }
  end
end
