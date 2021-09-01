include_set Abstract::FilterableBar

format :html do
  info_bar_cols 6, 4, 2

  view :bar_left do
    voo.size = :medium
    filterable({ dataset: card.name, status: :all }, class: "w-100") do
      render_thumbnail_with_bookmark
    end
  end

  view :bar_middle do
    field_nest :wikirate_topic
  end

  view :bar_right do
    count_badges :metric, :wikirate_company, :data_subset
  end

  view :bar_bottom do
    [main_progress_bar, dataset_details]
  end

  def thumbnail_subtitle
    output [field_nest(:organizer, view: :credit), render_default_research_progress_bar]
  end

  def data_subset_detail
    return if card.parent.blank?
    labeled_field :parent, :link, title: "Subdataset of"
  end
end
