def key_type_id
  WikirateCompanyID
end

def filter_by_key company
  return true unless (filter = company_filter)
  filter.include? company
end

def filter_by_values _key, values
  filter_by_value(values) #&& filter_by_year(values)
end

def filter_by_outliers key, value
  keep_if :value do |filter|
    filter != "outliers" || outliers.key?(outlier_key(key, value))
  end
end

def pass_single_value_filter? key, value
  filter_by_year(key, value) && filter_by_outliers(key, value)
end

private

def prepare_for_outlier_search
  res = {}
  values_by_name.map do |key, data|
    data.each do |row|
      next unless row["value"].number?
      res[outlier_key(key, row)] = row["value"].to_i
    end
  end
  res
end

def outlier_key key, row
  "#{key}+#{row["year"]}"
end

def turkey_outliers
  res = []
  values_by_name.map do |key, data|
    data.each do |row|
      next unless row["value"].number?
      res << [row["value"].to_i, outlier_key(key, row)]
    end
  end
  res.sort!
  return if res.size < 3
  quarter = res.size/3
  q1 = res[quarter]
  q3 = res[-quarter]
  res
end

def outliers
  @outliers ||= Savanna::Outliers.get_outliers prepare_for_outlier_search, :all
end


def company_filter
  filter = fetch_params params_keys
  return unless filter.present?
  Card.search search_wql(WikirateCompanyID, filter, params_keys, "name")
end
