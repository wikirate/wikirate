include_set Abstract::Tabs

format :html do
  view :core, wrap: :slot do
    [haml(:title), render_details]
  end

  view :details do
    [details_top, render_expanded_details]
  end

  view :other_year_links do
    return unless record_count > 1
    other_record_answers.map do |answer|
      modal_link answer.year.to_s, path: { mark: answer.name },
                                   size: :xl,
                                   "data-slotter-mode": "modal-replace"
    end.join ", "
  end

  def other_record_answers
    card.record_card.metric_answer_card.search.reject { |a| a.year == card.year }
  end

  def record_count
    @record_count ||= card.record_card.metric_answer_card.count
  end

  def record_filter_hash
    { status: :exists,
      metric_name: exactly(card.metric_name),
      company_name: exactly(card.company_name) }
  end

  def exactly name
    "=#{Card.fetch_name name}"
  end

  def details_top
    class_up "full-page-link", "metric-color"
    haml :details_top
  end

  view :company_header do
    nest card.company_card, view: :shared_header
  end

  view :metric_header do
    nest card.metric_card, view: :shared_header
  end
end
