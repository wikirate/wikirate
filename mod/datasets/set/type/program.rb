include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail

card_accessor :dataset, type: PointerID
card_accessor :metric

format :html do
  before :content_formgroups do
    voo.edit_structure = %i[
      image general_overview description dataset contact_us
    ]
  end

  view :bar_left do
    render :thumbnail
  end

  view :bar_right do
    count_badges :dataset, :metric
  end

  view :bar_bottom do
    field_nest :general_overview
  end

  bar_cols 7, 5

  view :data do
    wrap_with :div do
      [field_nest(:general_overview), field_nest(:description)]
    end
  end

  def tab_list
    %i[dataset metric]
  end

  view :dataset_tab do
    wrap_with :div do
      [datasets_list, standard_nest(:contact_us)]
    end
  end

  def datasets_list
    field_nest :dataset, view: :content, items: { view:  :bar }, title: "Datasets"
  end

  view :metric_tab do
    field_nest :metric, view: :content, items: { view:  :bar }, title: "Metrics"
  end
end
