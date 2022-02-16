
def inheritance_formula
  item_names.map do |item|
    "{{#{item} | not_researched: false}}"
  end.join " || "
end
