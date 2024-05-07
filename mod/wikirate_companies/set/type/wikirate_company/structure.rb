# IDENTIFIERS = %i[sec_cik].freeze
# INTEGRATIONS = %i[wikipedia oar_id open_corporates].freeze

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

  def header_list_items
    super.tap { |hash| add_header_items hash, %i[headquarters wikirate_website] }
  end

  def header_text
    render_contrib_switch
  end

  def tab_list
    if contrib_page?
      %i[metrics_designed research_group projects_organized details]
    else
      %i[metric_answer source company_group dataset details]
    end
  end

  def tab_options
    { projects_organized: { label: "Projects Organized" },
      metrics_designed: { label: "Metrics Designed" },
      company_group: { label: "Groups" } }
  end

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
    field_nest :company_group, view: :filtered_content,
                               items: { view: :bar, show: :full_page_link }
  end

  view :details_tab do
    [identifiers, integrations]
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

  private

  def add_header_items hash, field_codes
    field_codes.each do |field_code|
      next unless (content = card.fetch(field_code)&.content)&.present?
      hash[field_code.cardname] = content
    end
  end
end
