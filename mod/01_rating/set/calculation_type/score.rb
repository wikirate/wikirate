def normalize_value value
  return 0 if value < 0
  return 10 if value > 10
  value
end

