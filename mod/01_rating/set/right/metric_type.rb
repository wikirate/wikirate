event :reset_metrics_set_pattern_for_metric_type, after: :store do
  left.reset_patterns
  left.include_set_modules
end