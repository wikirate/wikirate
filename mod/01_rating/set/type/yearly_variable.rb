
format :html do
  view :thumbnail do |_args|
    wrap_with :div, class: 'metric-thumbnail' do
      card.name
    end
  end
end
