include_set Abstract::Search

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
    { "Recently Added": :create,
      "Alphabetical": :name }
  end
end

format :html do
  def export_formats
    []
  end

  def filter_output_type_type
    :radio
  end

  def quick_filter_list
    filter_output_type_options.map do |otype|
      { output_type: otype }
    end
  end

  # FIXME: duplicate of right/output_type
  def filter_output_type_options
    %w[publication dashboard]
  end
end

class OutputFilterQuery < Card::FilterQuery
  def output_type_cql value
    return unless value.present?
    add_to_cql :right_plus, [OutputTypeID, { refer_to: value }]
  end
end
