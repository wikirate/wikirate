card_accessor :latest_value_year, :type=>:phrase

def latest_value_card
  Card.fetch "#{name}+#{latest_value_year}"
end

def update_latest_value_year
  year =
    if (metric_value = Card.search(:left=>name, :right=>{:type=>'year'},:dir=>'asc',:limit=>1, :return=>'name').first)
      metric_value.to_name.right
    else
      ''
    end
  Auth.as_bot do
    latest_value_year_card.update_attributes! :content=>year
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
