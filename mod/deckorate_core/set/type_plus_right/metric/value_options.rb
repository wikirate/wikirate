include_set Abstract::MetricChild, generation: 1
include_set Abstract::StewardPermissions
include_set Abstract::PublishableField

event :validate_no_commas_in_value_options, :validate,
      skip: :allowed, # until we fix all the bad ones
      on: :save, changed: :content do
  return unless metric_card&.multi_categorical? && options_hash.values.join.match?(",")

  errors.add :content, "Multi-category options cannot have commas"
end

event :validate_value_options_match_values, :validate,
      skip: :allowed,  # should only be skipped when fixing bad data.
      on: :save, when: :categorical?, changed: :content do
  return unless (error_message = metric_card.validate_all_values)

  errors.add :content, "Change makes current answers invalid: #{error_message}"
end

def item_names args={}
  super args.merge(context: :raw)
end

def item_cards args={}
  item_names(args).map(&:card)
end

def options_hash
  json_options? ? parse_content : option_hash_from_names
end

def options_hash_with_unknown
  options_hash.tap do |hash|
    hash["Unknown"] = "Unknown"
  end
end

def json_options?
  type_id == Card::JsonID
end

def option_hash_from_names
  item_names.each_with_object({}) { |name, hash| hash[name] = name }
end

def count
  item_names.size
end

def delistable?
  false
end

format :html do
  def default_item_view
    :name
  end

  def default_limit
    50
  end

  view :core do
    wrap_with :div, class: "pointer-list" do
      card.item_names.map do |item_name|
        wrap_with :div, item_name, class: "pointer-item item-name"
      end
    end
  end

  # view :core do
  #   filtering(".RIGHT-answer ._compact-filter") do
  #     wrap_with :div, class: "pointer-list" do
  #       card.item_names.map do |name|
  #         card.metric_card.relation? ? name : filterable_div(name)
  #       end
  #     end
  #   end
  # end
  #
  # def filterable_div item_name
  #   wrap_with :div, item_name,
  #             class: "pointer-item item-name _filterable",
  #             data: { filter: { value: card.item_value(item_name) } }
  # end
end

format :json do
  view :option_list do
    card.options_hash_with_unknown.map.with_object([]) do |(name, key), array|
      array << { name: name, key: key }
    end
  end
end
