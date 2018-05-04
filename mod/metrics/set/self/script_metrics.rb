include_set Abstract::CodeFile
Self::ScriptMods.add_to_basket :item_codenames, :script_metrics

FILE_NAMES =
  %w[
    metrics
    metric_value
    value_type
    drag_and_drop
    metric_chart
  ].freeze

def source_files
  coffee_files FILE_NAMES
end
