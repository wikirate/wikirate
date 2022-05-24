include_set Abstract::Tabs

format :html do
  # def tab_list
  #   list = [:details]
  #   list << :metric if voo.show? :metric_header
  #   list << :wikirate_company if voo.show? :company_header
  #   list
  # end
  #
  # def tab_options
  #   {
  #     details:          { label: "Answer" },
  #     metric:           { label: "Metric", count: nil },
  #     wikirate_company: { label: "Company", count: nil }
  #   }
  # end
  #
  # view :details_tab do
  #   render_details
  # end
  #
  # view :metric_tab do
  #   nest card.metric_card, view: :details_tab
  # end
  #
  # view :wikirate_company_tab do
  #   nest card.company_card, view: :details_tab
  # end

  view :core, wrap: :slot do
    [haml(:title), render_details]
  end

  view :details do
    [details_top, render_expanded_details]
  end

  view :other_year_links do
    return unless record_count > 1
    other_record_answers.map do |answer|
      link_to answer.year.to_s, href: answer.name.url_key, class: "_update-details"
    end.join ", "
  end

  def other_record_answers
    card.record_card.metric_answer_card.search.reject { |a| a.year == card.year }
  end

  def record_count
    @record_count ||= card.record_card.metric_answer_card.count
  end

  # view :record_filter_button, cache: :never do
  #   filter_for_record do
  #     link_to_card card.record_card, ,
  #                  class: "btn btn-sm btn-outline-secondary"
  #   end
  # end

  # def filter_for_record
  #   filterable record_filter_hash, class: "record-filter" do
  #     yield
  #   end
  # end

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
