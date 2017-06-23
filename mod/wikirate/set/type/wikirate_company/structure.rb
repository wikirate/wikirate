include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

card_accessor :wikipedia
card_accessor :open_corporates

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [:image, :wikipedia]
  end

  def active_profile_tab
    (profile = params[:company_profile]) ? profile.to_sym : default_profile_tab
  end

  def default_profile_tab
    @default_profile_tab ||=
      show_contributions_profile? ? :contributions : :performance
  end

  def tab_list
    list = { details_tab: two_line_tab("Details", fa_icon("info")) }
    list.merge! performance_tabs if active_profile_tab == :performance
    list
  end

  def performance_tabs
    {
      topics_tab: tab_count_title(:wikirate_topic),
      sources_tab: tab_count_title(:source),
      projects_tab: tab_count_title(:project)
    }
  end

  view :data, cache: :never do
    if active_profile_tab == :performance
      output [
        _optional_render_header_tabs_mobile,
        field_nest(:all_metric_values)
      ]
    else
      contribution_data
    end
  end

  def header_right
    output [
      wrap_with(:h3, _render_title, class: "company-color"),
      _render_header_tabs
    ]
  end

  view :header_tabs, cache: :never do
    wrap_header_tabs
  end

  view :header_tabs_mobile, cache: :never do
    wrap_header_tabs :mobile
  end

  def wrap_header_tabs device=""
    css_class = "nav nav-tabs company-profile-tab"
    css_class += device.to_sym == :mobile ? " visible-xs" : " hidden-xs"
    wrap_with :ul, class: css_class do
      [performance_tab_button, contributions_tab_button]
    end
  end

  def contribution_data
    output [_render_metric_contributions, _render_project_contributions]
  end

  def profile_tab key, label, args={}
    add_class args, :active if active_profile_tab == key
    wrap_with :li, args do
      link_to_card card, label, path: { company_profile: key }
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
      disabled_tab = wrap_with :span, label_name
      wrap_with :li, disabled_tab, class: "disabled"
    end
  end

  view :details_tab do |_args|
    bs_layout do
      row 12 do
        column country_table
      end
      row 12 do
        column integrations
      end
    end
  end

  def country_table
    table country_rows, class: "table-borderless table-condensed"
  end

  def country_rows
    [:headquarters, :incorporation].map do |field|
      [wrap_with(:strong, Card[field].name),
       field_nest(field, view: :content, show: :menu, items: { view: :name })]
    end
  end

  def integrations
    <<-HTML
      <h3>Integrations</h3>
      #{wikipedia_extract}
      #{open_corporates_extract}
    HTML
  end

  def wikipedia_extract
    nest card.wikipedia_card, view: :titled, title: "Wikipedia"
  end

  def open_corporates_extract
    nest card.open_corporates_card, view: :titled, title: "OpenCorporates"
  end

  view :topics_tab do
    field_nest :wikirate_topic, view: :topic_list_with_metric_counts
  end

  view :sources_tab do
    field_nest(:source, view: :content, items: { view: :listing })
  end

  view :projects_tab do
    field_nest :project, items: { view: :listing }
  end

  view :filter do |args|
    field_subformat(:company_metric_filter)._render_core args
  end

  view :browse_item, template: :haml

  view :homepage_item, template: :haml
end
