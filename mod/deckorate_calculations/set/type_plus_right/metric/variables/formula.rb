format :html do
  view :table do
    table table_rows, header: %w[Variable Metric Options]
  end

  def table_rows
    card.hash_list.clone.map do |hash|
      [hash.delete(:name),
       nest(hash.delete(:metric), view: :thumbnail),
       options_cell(hash)]
    end
  end

  def options_cell options
    haml :options_cell, options: options
  end
end