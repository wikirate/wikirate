include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

card_accessor :wikipedia
card_accessor :open_corporates

format :html do

  def default_content_formgroup_args _args
    voo.edit_structure = [:headquarters, :image, :wikipedia]
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
    active_profile_tab == :performance ? performance_data : contribution_data
  end

  def performance_data
    field_nest(:all_metric_values)
  end

  def header_right
    output [header_title, _render_header_tabs]
  end

  def header_title
    wrap_with :h3, _render_title, class: "company-color"
  end

  view :header_tabs, cache: :never do
    wrap_header_tabs
  end

  view :header_tabs_mobile, cache: :never do
    wrap_header_tabs(:mobile)
  end

  view :rich_header_mobile do
    wrap_with :div, _render_rich_header, class: "d-block d-md-none"
  end

  view :content_right_col do
    wrap_with :div do
      [
      _render_header_tabs_mobile,
      _render_rich_header_mobile,
      _render_tabs
      ]
    end
  end

  def left_column_class
    "left-col order-2 order-md-1 hide-header-sm"
  end

  def right_column_class
    "right-col order-1 order-md-2"
  end

  def wrap_header_tabs device=""
    css_class = "nav nav-tabs twin-tab " + header_tab_classes(device)
    wrap_with :ul, class: css_class do
      [performance_tab_button, contributions_tab_button]
    end
  end

  def header_tab_classes device
    if device.to_sym == :mobile
      "d-flex d-md-none"
    else
      "d-none d-md-inline company-profile-tab"
    end
  end

  def contribution_data
    output [_render_metric_contributions, _render_project_contributions]
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
      disabled_tab = wrap_with :span, label_name, class: "nav-link"
      wrap_with :li, disabled_tab, class: "disabled"
    end
  end

  view :details_tab do |_args|
    bs_layout do
      row 12 do
        column do
          output [country_table, integrations]
        end
      end
    end
  end

  def country_table
    table country_rows,
          class: "table-borderless table-condensed mt-3 h5 font-weight-normal"
  end

  def country_rows
    [:headquarters].map do |field|
      [{ content: wrap_with(:strong, Card[field].name),
         class: "no-stretch padding-right-30 pl-0" },
       field_nest(field, view: :content, show: :menu, items: { view: :name })]
    end
  end

  def integrations
    output [
      content_tag(:h5, "INTEGRATIONS", class: "border-bottom pb-2"),
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

  view :topics_tab do
    field_nest :wikirate_topic, view: :topic_list_with_metric_counts
  end

  view :sources_tab do
    field_nest(:source, view: :content, items: { view: :listing })
  end

  view :projects_tab do
    field_nest :project, items: { view: :listing }
  end

  # view :filter do |args|
  #   filter_form  a: { input_field: "<input class='a'/>", label: "A" },
  #                                    b: { input_field: "<select class='b'/>", label: "B" }
  #   # field_subformat(:company_metric_filter)._render_core args
  # end

  view :browse_item, template: :haml
  view :homepage_item, template: :haml
  view :homepage_item_sm, template: :haml
end
