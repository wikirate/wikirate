include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

card_accessor :wikipedia
card_accessor :open_corporates
card_accessor :post

format :html do
  before :content_formgroup do
    voo.edit_structure = [:headquarters, :image, :wikipedia]
  end

  def tab_list
    list = %i[details wikirate_topic source post project]
    list.insert(1, :contributions) # if contributions_made?
    list
  end

  def tab_options
    { contributions: { count: nil, label: "Contributions" } }
  end

  view :wikirate_topic_tab do
    field_nest :wikirate_topic, items: { view: :bar }
  end

  view :source_tab do
    field_nest :source, items: { view: :bar }
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end

  view :contributions_tab do
    [render_metric_contributions, render_project_contributions]
  end

  view :data do
    field_nest :metric_answer
  end

  def header_right
    wrap_with :h3, render_title, class: "company-color p-2"
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

  def contribution_data
    output [_]
  end

  def profile_tab key, label, args={}
    add_class args, :active if active_profile_tab == key
    wrap_with :li do
      add_class args, "nav-link"
      link_to_card card, label, path: { company_profile: key }, class: args[:class]
    end
  end

  def performance_tab_button
    profile_tab :performance, "Performance"
  end

  def contributions_tab_button
    label_name = "Contributions"
    if contributions_made?
      profile_tab :contributions, label_name
    else
      wrap_with :li, class: "disabled" do
        wrap_with :span, label_name, class: "nav-link"
      end
    end
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
