include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout
include_set Abstract::Filterable

card_accessor :wikipedia
card_accessor :open_corporates
card_accessor :post

format :html do
  before :content_formgroup do
    voo.edit_structure = [:headquarters, :image, :wikipedia]
  end

  def tab_list
    list = %i[details wikirate_topic source project]
    list.insert(1, :contributions) if contributions_made?
    list
  end

  def tab_options
    { contributions: { count: nil, label: "Contributions" } }
  end

  view :wikirate_topic_tab do
    filtering { field_nest :wikirate_topic, items: { view: :bar } }
  end

  view :source_tab do
    field_nest :source, items: { view: :bar }
  end

  view :project_tab do
    filtering { field_nest :project, items: { view: :bar } }
  end

  view :contributions_tab do
    [render_metric_contributions, render_project_contributions]
  end

  view :data do
    field_nest :metric_answer
  end

  def header_right
    wrap_with :h3, class: "company-color" do
      link_to_card card, nil, class: "inherit-anchor"
    end
  end

  view :rich_header_body do
    text_with_image title: "", text: header_right, size: :medium
  end

  def left_column_class
    "left-col order-2 order-md-1 hide-header-sm"
  end

  def right_column_class
    "right-col order-1 order-md-2"
  end

  view :details_tab do
    bs_layout do
      row 12 do
        column do
          output [properties, integrations]
        end
      end
    end
  end

  def properties
    field_nest :headquarters, title: "Headquarters",
                              view: :labeled, items: { view: :name }
  end

  def integrations
    output [
      content_tag(:h3, "Integrations"),
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
