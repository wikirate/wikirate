include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout
include_set Abstract::Filterable

card_accessor :wikipedia
card_accessor :open_corporates
card_accessor :post

format :html do
  # EDITING

  before :content_formgroup do
    voo.edit_structure = [:headquarters, :image, :wikipedia]
  end

  # LEFT SIDE

  def left_column_class
    "left-col order-2 order-md-1 hide-header-sm"
  end

  def header_body size=:medium
    class_up "media-heading", "company-color"
    super
  end

  def header_text
    return unless contribs_made?

    if contrib_page?
      switch_to :wikirate_company, "N", title: "Company performance profile"
    else
      switch_to :user, "Y", title: "Content contributions to WikiRate.org"
    end
  end

  def switch_to icon, val, opts={}
    opts.merge! class: "company-switch", path: { contrib: val }
    link_to_card card, mapped_icon_tag(icon), opts
  end

  view :data do
    if contrib_page?
      render_contributions_data
    else
      field_nest :metric_answer
    end
  end

  # RIGHT SIDE

  def right_column_class
    "right-col order-1 order-md-2"
  end

  def tab_list
    if contrib_page?
      %i[projects_organized details]
    else
      %i[details wikirate_topic source project]
    end
  end

  def tab_options
    { projects_organized: { label: "Projects Organized" } }
  end

  view :wikirate_topic_tab do
    filtering { field_nest :wikirate_topic, items: { view: :bar } }
  end

  view :source_tab do
    filtering { field_nest :source, items: { view: :bar } }
  end
  
  view :project_tab do
    filtering { field_nest :project, items: { view: :bar } }
  end

  view :details_tab do
    details
  end

  def details
    output [labeled_field(:headquarters), integrations]
  end

  def integrations
    output [
      content_tag(:h1, "Integrations"),
      wikipedia_extract,
      open_corporates_extract
    ]
  end

  def wikipedia_extract
    nest card.wikipedia_card, view: :titled, title: "Wikipedia"
  end

  def open_corporates_extract
    nest card.open_corporates_card, view: :titled, title: "OpenCorporates"
  end
end
