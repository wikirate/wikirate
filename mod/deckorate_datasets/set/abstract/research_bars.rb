include_set Abstract::KnownRecords
include_set Abstract::Media

def virtual?
  new?
end

format :html do
  delegate :dataset_card, :project_name, to: :card

  bar_cols 6, 2, 4
  mini_bar_cols 8, 4

  view :bar_right do
    render :research_progress_bar
  end

  view :research_button, cache: :never do
    link_to "Research",
            class: "btn btn-outline-secondary btn-sm " \
                   "research-answer-button _over-card-link",
            path: { mark: record_log_name, project: project_name, view: :research }
  end

  view :bar_bottom do
    nest dataset_card, view: :bar_bottom
  end

  def dataset_name
    dataset_card.name
  end
end
