include Card::CachedCount  # used to cache year of latest metric value

def latest_value_year
  cached_count
end

def latest_value_card
  return if !(lvy = latest_value_year) || lvy == 0
  Card.fetch "#{name}+#{latest_value_year}"
end

expired_cached_count_cards set: Card::Set::Type::MetricValue do |changed_card|
  changed_card.left
end

# returns year of latest metric value
def calculate_count
  (metric_value = search_latest_value_name) && metric_value.to_name.right.to_i
end

def search_latest_value_name
  Card.search(left: name, right: { type: 'year' },
              dir: 'asc',
              limit: 1,
              return: 'name').first
end

format :html do
  def default_menu_args args
    args[:optional_horizontal_menu] = :hide
  end

  view :all_values do |args|
    values = Card.search left: card.name,
                         type: Card::MetricValueID,
                         sort: 'name', dir: 'desc'
    values.map.with_index do |v, i|
      <<-HTML
        <span data-year="#{v.year}" data-value="#{v.value}"
              #{'style="display: none;"' if i > 0}>
          #{subformat(v).render_concise(args)}
        </span>
      HTML
    end
  end
end
