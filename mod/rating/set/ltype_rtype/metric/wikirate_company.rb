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
