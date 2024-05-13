card_accessor :headquarters, type: :pointer

def self.corporate_identifier_accessor codename
  card_accessor codename, type: :phrase if codename.present? && !method_defined?(codename)
end

def corporate_identifiers
  @corporate_identifiers ||= CorporateIdentifier.names
end

def corporate_identifiers_with_excerpts
  @corporate_identifiers_with_excerpts ||= CorporateIdentifier.excerpts
end

def corporate_identifiers_without_excerpts
  @corporate_identifiers_without_excerpts ||= CorporateIdentifier.non_excerpts
end

# as in, NOT records (company+metric)
def simple_field_names
  %i[image headquarters wikirate_website alias].map(&:cardname) + corporate_identifiers
end

def simple_field_cards
  simple_field_names.map { |field| fetch field }.compact
end

format :html do
  # EDITING

  before :content_formgroups do
    voo.edit_structure = card.simple_field_names
  end

  def header_list_items
    super.tap { |hash| add_header_items hash, %i[headquarters wikirate_website] }
  end

  def header_text
    render_contrib_switch
  end

  def tab_list
    if contrib_page?
      %i[details metrics_designed research_group projects_organized]
    else
      %i[details metric_answer source company_group dataset]
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
    card.corporate_identifiers_without_excerpts.map do |code|
      labeled_field code, :name if card.fetch(code)
    end
  end

  def integrations
    card.corporate_identifiers_with_excerpts.map do |fieldcode|
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
