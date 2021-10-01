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
    dataset_details
  end

  def thumbnail_subtitle
    field_nest :year, view: :one_line_content, items: { view: :name }, unknown: :blank
  end

  def data_subset_detail
    labeled_field :parent, :link, title: "Data Subset of" unless card.parent.blank?
  end
end
