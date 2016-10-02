format do
  def sort values
    sorted = case sort_by
    when "name", "company_name"
      sort_name_asc values
    when "value"
      sort_value_asc values, num?
    else
      values
    end
    sort_order == "asc" ? sorted : sorted.reverse
  end
end