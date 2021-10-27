include_set Abstract::Filterable

# card_accessor :post

IDENTIFIERS = %i[headquarters sec_cik oar_id].freeze
INTEGRATIONS = %i[wikipedia open_corporates].freeze
UNKNOWN_IDENTIFIER_VIEW = { headquarters: :unknown }.freeze

(IDENTIFIERS + INTEGRATIONS).each { |field| card_accessor field, type: PhraseID }

def field_cards
  (IDENTIFIERS + INTEGRATIONS).map { |field| fetch field }.compact
end

format :html do
  # EDITING

  before :content_formgroups do
    voo.edit_structure = [:image] + IDENTIFIERS + INTEGRATIONS
  end

  # LEFT SIDE
  #
  def header_body
    class_up "media-heading", "company-color"
    super
  end

  def header_text
    contribs_made? ? render_contrib_switch : ""
  end

  view :data, cache: :never do
    if contrib_page?
      render_contributions_data
    else
      field_nest :metric_answer, view: :filtered_content
    end
  end

  # RIGHT SIDE

  def tab_list
    if contrib_page?
      %i[research_group projects_organized details]
    else
      %i[details wikirate_topic company_group source dataset]
    end
  end

  def tab_options
    { research_group: { label: "Research Groups" },
      projects_organized: { label: "Projects Organized" },
      company_group: { label: "Groups" } }
  end

  def answer_filtering
    filtering(".RIGHT-answer ._filter-widget") do
      yield view: :bar, show: :full_page_link, hide: %i[company_header edit_link]
    end
  end

  view :wikirate_topic_tab do
    answer_filtering do |items|
      field_nest :wikirate_topic, view: :filtered_content, items: items
    end
  end

  view :source_tab do
    answer_filtering do |items|
      field_nest :source, view: :filtered_content, items: items
    end
  end

  view :dataset_tab do
    answer_filtering { |items| field_nest :dataset, items: items }
  end

  view :company_group_tab do
    field_nest :company_group, items: { view: :bar, show: :full_page_link }
  end

  view :details_tab do
    [identifiers, content_tag(:h1, "Integrations"), integrations]
  end

  def identifiers
    IDENTIFIERS.map do |code|
      labeled_field code, :name, unknown: (UNKNOWN_IDENTIFIER_VIEW[code] || :blank)
    end
  end

  def integrations
    INTEGRATIONS.map { |fieldcode| field_nest fieldcode, view: :titled }
  end
end
