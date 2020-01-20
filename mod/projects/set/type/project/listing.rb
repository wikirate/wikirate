include_set Abstract::FilterableBar

format :html do
  info_bar_cols 6, 4, 2

  view :bar_left do
    voo.size = :medium
    filterable({ project: card.name, status: :all }, class: "w-100") do
      render_thumbnail_with_bookmark
    end
  end

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
    output [field_nest(:organizer, view: :credit), render_default_research_progress_bar]
  end

  def subproject_detail
    return if card.parent.blank?
    labeled_field :parent, :link, title: "Subproject of"
  end
end
