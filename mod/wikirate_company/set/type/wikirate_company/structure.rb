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

  def header_body
    class_up "media-heading", "company-color"
    super
  end

  def header_text
    contribs_made? ? render_contrib_switch : ""
  end

  view :data do
    if contrib_page?
      render_contributions_data
    else
      field_nest :metric_answer
    end
  end

  # RIGHT SIDE

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

  def answer_filtering
    filtering(".RIGHT-answer ._filter-widget") do
      yield view: :bar, show: :full_page_link
    end
  end

  view :wikirate_topic_tab do
    answer_filtering do |items|
      nest [:wikirate_topic, :browse_topic_filter], view: :filtered_content, items: items
    end
  end

  view :source_tab do
    answer_filtering do |items|
      field_nest :source, view: :filtered_content, items: items
    end
  end

  view :project_tab do
    answer_filtering { |items| field_nest :project, items: items }
  end

  view :details_tab do
    [labeled_field(:headquarters), integrations]
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
