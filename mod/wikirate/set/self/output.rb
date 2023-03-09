include_set Abstract::Search

OUTPUT_TYPE_OPTIONS = %w[publication dashboard].freeze

def item_type_id
  OutputID
end

format do
  def filter_class
    OutputFilterQuery
  end

  def default_sort_option
    "create"
  end

  def filter_map
    %i[output_type]
  end

  def default_filter_hash
    { output_type: "" }
  end

  def sort_options
    {}
  end
end

format :html do
  view :filter_chips, template: :haml

  def filter_output_type_options
    OUTPUT_TYPE_OPTIONS
  end

  def selected_output_types
    filter_hash[:output_type]
  end

  def option_selected? option
    Array.wrap(selected_output_types).include? option
  end

  # following not used yet...

  # def export_formats
  #   []
  # end
  #
  # def filter_output_type_type
  #   :radio
  # end
  #
  # def quick_filter_list
  #   filter_output_type_options.map do |otype|
  #     { output_type: otype }
  #   end
  # end
  #
end

# class for managing custom filters for outputs
class OutputFilterQuery < Card::FilterQuery
  def output_type_cql value
    return unless value.present?


    value = [:in] + value if value.is_a? Array
    add_to_cql :right_plus, [:output_type, { refer_to: value }]
  end
end
