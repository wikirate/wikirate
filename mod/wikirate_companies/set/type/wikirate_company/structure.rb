IDENTIFIERS = %i[sec_cik].freeze
INTEGRATIONS = %i[wikipedia oar_id open_corporates].freeze

card_accessor :headquarters, type: :pointer
(IDENTIFIERS + INTEGRATIONS).each { |field| card_accessor field, type: :phrase }

def field_cards
  ([:headquarters] + IDENTIFIERS + INTEGRATIONS).map { |field| fetch field }.compact
end

format :html do
  # EDITING

  before :content_formgroups do
    voo.edit_structure = %i[image headquarters] + IDENTIFIERS + INTEGRATIONS
  end

  def header_middle_items
    super.tap do |h|
      if (hq = card.headquarters).present?
        h[:Headquarters] = hq
      end
    end
  end

  def tab_list
    if contrib_page?
      %i[metrics_designed research_group projects_organized details]
    else
      %i[metric_answer source company_group dataset details]
    end
  end

  def tab_options
    { research_group: { label: "Research Groups" },
      projects_organized: { label: "Projects Organized" },
      company_group: { label: "Groups" } }
  end

  # def answer_filtering
  #   filtering(".RIGHT-answer ._compact-filter") do
  #     yield view: :bar, show: :full_page_link, hide: %i[company_header edit_link]
  #   end
  # end

  # view :wikirate_topic_tab do
  #   answer_filtering do |items|
  #     field_nest :wikirate_topic, view: :filtered_content, items: items
  #   end
  # end

  view :metric_answer_tab do
    field_nest :metric_answer, view: :filtered_content
  end

  view :source_tab do
    field_nest :source, view: :filtered_content
  end

  view :dataset_tab do
    field_nest :dataset, view: :filtered_content
  end

  view :company_group_tab do
    field_nest :company_group, items: { view: :bar, show: :full_page_link }
  end

  view :details_tab do
    [labeled_field(:headquarters, :name), identifiers, integrations]
  end

  def identifiers
    IDENTIFIERS.map do |code|
      labeled_field code, :name if card.fetch(code)
    end
  end

  def integrations
    INTEGRATIONS.map do |fieldcode|
      next unless card.fetch fieldcode

      field_nest fieldcode, view: :titled, title: fieldcode.cardname
    end
  end
end
