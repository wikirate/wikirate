# Sorts and groups OpenCorporates' jurisdictions by country.
# The resulting array has the format that the select2 library expects
# to define a option list for a select field.
class CountryGroups < Array
  def initialize cards=nil
    cards ||= Card.search(type_id: JurisdictionID)
    @groups = Hash.new { |hash, key| hash[key] = {} }
    process_cards cards
    sanitize_and_sort
  end

  # The jurisdiction names from OpenCorporates sometimes have
  # the country of a state in brackets like "California (United States)".
  # We group these by country. But there are also
  # entries that have a clarification in brackets like "Holy See (Vatican City State)"
  # So if a group has only one child at the end we remove the group and put the "country"
  # back into brackets
  def process_cards cards
    cards.each do |card|
      if (m = card.name.match(/(?<state>.+?)\s*\((?<country>[^)]+)\)/))
        add_state card, m[:country], m[:state]
      else
        add_country card
      end
    end
  end

  def sanitize_and_sort
    @groups.keys.sort.each do |country|
      group = @groups[country]
      group.key?(:children) ? sanitize_group(country, group) : (self << group)
    end
  end

  def add_state card, country, state
    @groups[country][:text] ||= country
    @groups[country][:children] ||= []
    @groups[country][:children] << { id: card.codename, text: state }
  end

  def add_country card
    @groups[card.name][:text] ||= card.name
    @groups[card.name][:id] = card.codename
  end

  def sanitize_group country, group
    if group[:children].size > 1 # valid group
      # the group header is an item itself
      self << { id: group.delete(:id), text: group[:text] } if group.key?(:id)
      sort_children group
      self << group
    else  # just a single item; remove the group
      child = group[:children].first
      child[:text] = "#{child[:text]} (#{country})"
      self << child
    end
  end

  def sort_children group
    group[:children].sort! { |a, b| a[:text] <=> b[:text] }
  end
end

format :json do
  view :select2, cache: :never do
    { results: select2_option_list }.to_json
  end

  def select2_option_list
    if name_query
      wql = { type_id: JurisdictionID, name: ["match", name_query] }
      Card.search(wql).each_with_object([]) do |i, ar|
        ar << { id: i.codename, text: i.name }
      end
    else
      CountryGroups.new
    end
  end

  def name_query
    Env.params[:q] if Env.params[:q].present?
  end
end
