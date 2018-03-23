include_set Abstract::TwoColumnLayout

TAB_MAP = {
  company:    [ :num_companies,    "Companies",   :building ],
  metric:     [ :num_metrics,      "Metrics",     "bar-chart"],
  year:       [ :num_years,        "Years",       :calendar ],
  subproject: [ :num_subprojects,  "Subprojects", :flask ]
}.freeze

format :html do
  view :open_content do
    two_column_layout 5, 7
  end

  def default_content_formgroup_args _args
    voo.edit_structure = [
      :image,
      :wikirate_status,
      :parent,
      :organizer,
      :wikirate_topic,
      :description,
      :year,
      :metric,
      :wikirate_company
    ]
  end

  def project_type_name
    return with_parent unless card.parent.blank?
    card.type.upcase
  end

  def with_parent
    parent = link_to_card(card.parent_card.item_cards.first)
    "SUB-#{card.type.upcase} (of #{parent})"
  end

  def header_right
    wrap_with :div, class: "header-right" do
      [
        wrap_with(:h6, project_type_name, class: "text-muted border-bottom pt-2 pb-2"),
        wrap_with(:h5, _render_title, class: "project-title font-weight-normal")
      ].compact
    end
  end

  view :rich_header_body do
    output [
      (text_with_image title: "", text: header_right, size: :medium),
      status_field,
      # parent_field
    ]
  end

  def status_field
    field_nest :wikirate_status, view: :labeled,
                                 items: { view: :name },
                                 class: "labeled-pointer"
  end

  def parent_field
    return if card.parent.blank?
    field_nest :parent, view: :labeled, items: { view: :link }
  end

  view :data do
    wrap_with :div, class: "project-details" do
      project_details
    end
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [overall_progress_box, _render_tabs, _render_export_links]
    end
  end

  def active_tabs
    [:company, :metric, (:year if card.years), :subproject].compact
  end

  def tab_list
    active_tabs.each_with_object({}) do |tab, hash|
      stat_method, title, icon = TAB_MAP[tab]
      stat = card.send stat_method
      hash["#{tab}_tab".to_sym] = two_line_tab(([fa_icon(icon), title].join " "), stat)
    end
  end

  view :metric_tab do
    tab_nest :metric
  end

  view :company_tab do
    tab_nest :wikirate_company
  end

  view :year_tab do
    tab_nest :year
  end

  view :subproject_tab, template: :haml

  def copied_project_fields
    %i[wikirate_topic description].each_with_object({}) do |fld, hash|
      hash["_#{fld.cardname}"] = card.fetch(trait: fld, new: {}).content
    end
  end
end
