format do
  def sort values
    sorted = case card.sort_by
             when "name", "company_name"
               sort_name_asc values
             when "value"
               sort_value_asc values, num?
             else
               values
             end
    card.sort_order == "asc" ? sorted : sorted.reverse
  end
end
