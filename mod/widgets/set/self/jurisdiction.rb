format :json do

  view :select2 do
    { results: select2_option_list }.to_json
  end

  def select2_option_list
    if name_query
      wql = { type_id: JurisdictionID,
              name:  ["match", name_query] }
      Card.search(wql).each_with_object([]) do |i, ar|
        ar << { id: i.codename, text: i.name }
      end
    else
      group_by_country
    end
  end

  # The jurisdiction names from OpenCorporates sometimes have
  # the country of a state in brackets like "California (United States)".
  # We group these by country. But there are also
  # entries that have a clarification in brackets like "Holy See (Vatican City State)"
  # So if a group has only one child at the end we remove the group and put the "country"
  # back into brackets
  def group_by_country
    h = Hash.new { |h, k| h[k] = {} }
    by_country = Card.search(type_id: JurisdictionID).each_with_object(h) do |i, groups|
      if (m = i.name.match(%r{(?<state>.+?)\s*\((?<country>[^)]+)\)}))
        groups[m[:country]][:text] ||= m[:country]
        groups[m[:country]][:children] ||= []
        groups[m[:country]][:children] << { id: i.codename, text: m[:state] }
      else
        groups[i.name][:text] ||= i.name
        groups[i.name][:id] = i.codename
      end
    end
    sanitize_and_sort_grouping by_country
  end

  def sanitize_and_sort_grouping by_country
    result = []
    by_country.keys.sort.each do |key|
      data = by_country[key]
      if data.key?(:children)
        if data[:children].size > 1   # valid group
          # group header is an item itself
          result << { id: data.delete(:id), text: data[:text] } if data.key?(:id)
          result << data
        else  # just a single item
          child = data[:children].first
          child[:text] = "#{child[:text]} (#{key})"
          result << child
        end
      else
        result << data
      end
    end
    result
  end

  def name_query
    Env.params[:q] if Env.params[:q].present?
  end
end
