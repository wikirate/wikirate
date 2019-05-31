include_set Abstract::FilterableBar

format :html do
  info_bar_cols 5, 5, 2

  view :bar_left do
    render_thumbnail
  end

  view :bar_middle, template: :haml

  view :bar_right do
    [count_badges(:metric, :wikirate_company),
     labeled_badge(card.percent_researched, "% Researched")]
  end

  view :bar_bottom do
    [main_progress_bar, project_details]
  end

  def thumbnail_subtitle_text
    field_nest :organizer, view: :credit
  end

  def subproject_detail
    return if card.parent.blank?
    labeled_field :parent, :link, title: "Subproject of"
  end
end
