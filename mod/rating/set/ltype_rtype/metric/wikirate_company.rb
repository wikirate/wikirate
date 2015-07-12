include Card::CachedCount  # used to cache year of latest metric value

def latest_value_year
  cc = cached_count
  cc.present? ? cc : update_cached_count
end

def latest_value_card
  if latest_value_year != 0
     Card.fetch "#{name}+#{latest_value_year}"
  end
end

expired_cached_count_cards :set=>Card::Set::Type::MetricValue do
   left.update_cached_count
end

def calculate_count
  year =
    if (metric_value = Card.search(:left=>name, :right=>{:type=>'year'},:dir=>'asc',:limit=>1, :return=>'name').first)
      metric_value.to_name.right.to_i
    else
      0
    end
end


format :html do

  def default_menu_args args
    args[:optional_horizontal_menu] = :hide
  end

  view :all_values do |args|
    values = Card.search :left=>card.name, :type=>Card::MetricValueID, :sort=>'name', :dir=>'desc'
    values.map.with_index do |v, i|
      %{
        <span data-year=#{v.year} data-value=#{v.value} #{'style="display: none;"' if i > 0}>#{subformat(v).render_concise(args)}</span>
      }
    end
  end
end
