include_set Abstract::TwoColumnLayout
include_set Abstract::Listing
include_set Abstract::Thumbnail

card_accessor :project, type: :pointer

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = %i[
      image general_overview description project contact_us
    ]
  end

  view :listing_left do
    render :thumbnail
  end

  view :listing_right do
    ""
  end

  view :listing_bottom do
    field_nest :description
  end

  view :data do
    wrap_with :div do
      [field_nest(:general_overview), field_nest(:description)]
    end
  end

  def tab_list
    {
      projects_tab: "Projects",
      metrics_tab: "#{fa_icon 'bar-chart'} Metrics"
    }
  end

  view :projects_tab do
    wrap_with :div do
      [projects_list, standard_nest(:contact_us)]
    end
  end

  def projects_list
    field_nest :project, view: :content, items: { view:  :listing }, title: "Projects"
  end

  view :metrics_tab do
    field_nest :metric, view: :content, items: { view:  :listing }, title: "Metrics"
  end
end
