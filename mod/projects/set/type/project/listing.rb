include_set Abstract::FilterableBar

format :html do
  info_bar_cols 5, 5, 2

  view :bar_left, template: :haml

  view :bar_middle do
    field_nest :wikirate_topic
  end

  view :bar_right do
    count_badges :metric, :wikirate_company, :subproject
  end

  view :bar_bottom do
    [main_progress_bar, project_details]
  end

  def thumbnail_subtitle
    field_nest :organizer, view: :credit
  end

  def subproject_detail
    return if card.parent.blank?
    labeled_field :parent, :link, title: "Subproject of"
  end
end
