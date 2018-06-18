VALID_DESIGNER_TYPE_IDS = [ResearchGroupID, UserID, WikirateCompanyID].freeze

def create_value_options options
  create_args = {
    name: name.field("value options"),
    content: options.to_pointer_content
  }
  Card.create! create_args
end

event :ensure_designer, :prepare_to_store, on: :save, changed: :name do
  return if valid_designer?
  if (card = Card[metric_designer])
    errors.add :metric_designer, "invalid type #{card.type_name}"
  else
    attach_subcard metric_designer, type_id: ResearchGroupID
  end
end

event :ensure_title, :prepare_to_store, on: :save, changed: :name do
  case Card.fetch_type_id(metric_title)
  when MetricTitleID
    return
  when nil
    attach_subcard metric_title, type_id: MetricTitleID
  else
    errors.add :metric_title, "#{metric_title} is a #{Card[metric_title].type_name} "\
                              "card and can be use as metric title"
  end
end

def valid_designer?
  Card.fetch_type_id(metric_designer).in? VALID_DESIGNER_TYPE_IDS
end

# @example
# create_values do
#   Siemens 2015 => 4, 2014 => 3
#   Apple   2105 => 7
# end
def create_values random_source=false, &block
  Card::Metric::ValueCreator.new(self, random_source, &block).add_values
end

def add_value_source_args args, source
  case source
  when String
    args["+source"] = {
      content: "[[#{source}]]",
      type_id: Card::PointerID
    }
  when Hash
    args["+source"] = source
  when Card
    args["+source"] = {
      content: "[[#{source.name}]]",
      type_id: Card::PointerID
    }
  end
end

def extract_metric_value_name args, error_msg
  args[:name] || begin
    missing = [:company, :year, :value].reject { |v| args[v] }
    if missing.empty?
      [name, args[:company], args[:year], args[:related_company]].compact.join "+"
    else
      error_msg.push("missing field(s) #{missing.join(',')}")
      nil
    end
  end
end

def check_value_card_exist args, error_msg
  return unless (value_name = extract_metric_value_name(args, error_msg))
  return if !(value_card = Card[value_name.to_name.field(:value)]) ||
            value_card.content.casecmp(args[:value]).zero?
  link = format.link_to_card value_card.metric_card, "value"
  error_msg << "#{link} '#{value_card.content}' exists"
end

def valid_value_args? args
  error_msg = []
  check_value_card_exist args, error_msg unless args.delete(:ok_to_exist)
  error_msg << "missing source" if metric_type_codename == :researched && !args[:source]
  error_msg.each do |msg|
    errors.add "metric value", msg
  end
  error_msg.empty?
end

def create_value_args args
  return unless valid_value_args? args
  value_name =
    [name, args[:company], args[:year], args[:related_company]].compact.join "+"
  type_id = args[:related_company] ? Card::RelationshipAnswerID : Card::MetricAnswerID
  create_args = {
    name: value_name,
    type_id: type_id,
    "+value" => {
      content: args[:value],
      type_id: (args[:value].is_a?(Integer) ? NumberID : PhraseID)
    }
  }
  create_args["+discussion"] = { comment: args[:comment] } if args[:comment].present?
  add_value_source_args create_args, args[:source]
  create_args
end

# @param [Hash] args
# @option args [String] :company
# @option args [String] :year
# @option args [String] :value
# @option args [String] :source source url
def create_value args
  unless (valid_args = create_value_args args)
    raise "invalid value args: #{args}"
  end
  Card.create! valid_args
end

# for override
def needs_name?
  !name.present?
end

# The new metric form has a title and a designer field instead of a name field
# We compose the card's name here
event :set_metric_name, :initialize, on: :create, when: :needs_name? do
  title = (tcard = remove_subfield(:title)) && tcard.content
  designer = (dcard = remove_subfield(:designer)) && dcard.content
  self.name = "#{designer}+#{title}"
end

format :html do
  view :new do
    voo.title = "New Metric"
    with_nest_mode :edit do
      frame { _render_new_form }
    end
  end

  view :new_form, template: :haml do
    @tabs =
      {
        researched: {
          help: "Answer values for <strong>Researched</strong> metrics are "\
                "directly entered or imported.",
          subtabs: %w[Standard Relationship]
        },
        calculated: {
          help: "Answer values for <strong>Calculated</strong> "\
                "metrics are dynamically calculated.",
          subtabs: %w[Formula Descendant Score WikiRating]
        }
      }
  end

  before :content_formgroup do
    voo.edit_structure = [["+question", "Question"],
                          [:wikirate_topic, "Topic"]]
  end

  def tab_pane_id name
    "#{name.downcase}Pane"
  end

  def selected_tab_pane? tab
    tab == current_tab
  end

  def current_tab
    @current_tab ||= begin
      subtab = params[:tab]&.underscore&.to_sym
      subtab && Card[subtab].calculated? ? :calculated : :researched
    end
  end

  def selected_subtab_pane? name
    if params[:tab]
      params[:tab].casecmp(name).zero?
    else
      name == "Standard" || name == "Formula"
    end
  end

  def new_metric_tab_pane name
    metric_type = name == "Standard" ? "Researched" : name
    new_metric = new_metric_of_type metric_type
    tab_form = nest new_metric, { view: :new_tab_pane }, nest_mode: :normal
    tab_pane tab_pane_id(name), tab_form, selected_subtab_pane?(name)
  end

  def new_metric_of_type metric_type
    new_metric = Card.new type: MetricID, "+*metric type" => "[[#{metric_type}]]"
    new_metric.reset_patterns
    new_metric.include_set_modules
    new_metric
  end

  def cancel_button_new_args
    { href: path_to_previous, redirect: true }
  end

  view :help_text do
    return "" unless (help_text_card = Card[card.metric_type + "+description"])
    class_up "help-text", "help-block"
    with_nest_mode :normal do
      render! :help, help: help_text_card.content
    end
  end

  view :new_tab_pane, tags: :unknown_ok do
    with_nest_mode :edit do
      wrap do
        card_form :create, "main-success" => "REDIRECT",
                           "data-slot-selector": ".new-view.TYPE-metric" do
          output [
            new_tab_pane_hidden,
            _render!(:help_text),
            _render_new_name_formgroup,
            _render_content_formgroup,
            _render_new_buttons
          ]
        end
      end
    end
  end

  def new_tab_pane_hidden
    hidden_tags(
      "card[subcards][+*metric type][content]" => "[[#{card.metric_type}]]",
      "card[type_id]" => MetricID,
      success: "_self"
    )
  end

  view :new_name_formgroup do
    formgroup "Metric Name", editor: "name", help: false do
      new_name_field
    end
  end

  def new_name_field form=nil, options={}
    form ||= self.form
    bs_layout do
      row 5, 1, 6 do
        column do
          metric_designer_field(options)
        end
        column do
          '<div class="plus">+</div>'
        end
        column do
          title_fields(options)
        end
      end
    end
  end

  def title_fields options
    metric_title_field(options)
  end

  def metric_designer_field options={}
    # I don't see a way to get options through to the form field
    # if options.present?
    #   label_tag(:designer, 'Metric Designer') +
    #     text_field('subcards[+designer]', {
    #       value: Auth.current.name,
    #       autocomplete: 'off'
    #     }.merge(options))
    # else
    designer = card.add_subfield :designer, content: Auth.current.name,
                                            type_id: PhraseID
    designer.reset_patterns
    designer.include_set_modules
    subformat(designer)
      ._render_edit_in_form(options.merge(title: "Metric Designer"))
    # end
  end

  def metric_title_field options={}
    title = card.add_subfield :title, content: card.name.tag,
                                      type_id: PhraseID
    title.reset_patterns
    title.include_set_modules
    subformat(title)._render_edit_in_form(options.merge(title: "Metric Title"))
  end
end
