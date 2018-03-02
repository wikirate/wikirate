
format :json do
  # view :content do
  #   card.companies_with_years_and_values.to_json
  # end

  view :core do
    card.all_answers.map do |answer|
      # nest answer, view: :essentials
      subformat(answer)._render_core
    end
  end

  def essentials
    {
        designer: card.metric_designer,
        title: card.metric_title
    }
  end
end


format :csv do
  view :core do
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end
end
