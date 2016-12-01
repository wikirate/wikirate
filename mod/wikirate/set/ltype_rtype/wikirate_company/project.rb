include_set Abstract::KnownAnswers
include_set Abstract::Media

def project_card
  @project_card ||= right
end

def company_card
  @company_card ||= left
end

def company_image
  company_card.fetch(trait: :image, new: {})
end

def metric_ids
  project_card.metric_ids
end

def records
  @records ||= metric_ids.size
end

def researched_wql
  { left_id: [:in] + metric_ids,
    right_id: company_card.id,
    return: :count }
end

def worth_counting
  return 0 unless metric_ids.any?
  yield
end

format :html do
  view :progress_bar_row, tags: :unknown_ok do
    wrap_with :div, class: "progress-bar-row" do
      [
        nest(card.company_card, view: :link),
        # should be company view shared with metric page
        research_progress_bar
      ]
    end
  end

  view :company_thumbnail do
    title = card.company_card.name
    text_with_image title: title, image: card.company_image, size: :icon
  end

  # TODO link to research page
  view :research_button do
    content_tag(:button, "Research", class: "btn btn-default btn-sm")
  end

  view :research_progress_bar do
    research_progress_bar
  end

  def research_progress_bar
    progress_bar(
      { value: card.percent_known, class: "progress-known" },
      { value: card.percent_unknown, class: "progress-unknown" },
      { value: card.percent_not_researched, class: "progress-not-researched" }
    )
  end
end
