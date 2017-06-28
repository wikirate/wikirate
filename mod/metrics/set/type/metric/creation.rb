def create_value_options options
  create_args = {
    name: cardname.field("value options"),
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
  Card.fetch_type_id(metric_designer).in? [ResearchGroupID, UserID,
                                           WikirateCompanyID]
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
      [name, args[:company], args[:year]].join "+"
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
  check_value_card_exist args, error_msg
  if metric_type_codename == :researched && !args[:source]
    error_msg << "missing source"
  end
  error_msg.each do |msg|
    errors.add "metric value", msg
  end
  error_msg.empty?
end

def create_value_args args
  return unless valid_value_args? args
  value_name =
    [name, args[:company], args[:year], args[:related_company]].compact.join "+"
  type_id = args[:related_company] ? Card::RelationshipAnswerID : Card::MetricValueID
  create_args = {
    name: value_name,
    type_id: type_id,
    "+value" => {
      content: args[:value],
      type_id: (args[:value].is_a?(Integer) ? NumberID : PhraseID)
    }
  }
  if args[:comment].present?
    create_args["+discussion"] = { comment: args[:comment] }
  end
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

# The new metric form has a title and a designer field instead of a name field
# We compose the card's name here
event :set_metric_name, :initialize, on: :create, when: :needs_name? do
  title = (tcard = remove_subfield(:title)) && tcard.content
  designer = (dcard = remove_subfield(:designer)) && dcard.content
  self.name = "#{designer}+#{title}"
end

format :html do
  view :new do |_args|
    voo.title = "New Metric"
    frame do
      _render_new_form
    end
  end

  view :new_form, template: :haml do
    @tabs = %w[Researched Formula Score WikiRating]
  end

  def default_content_formgroup_args _args
    voo.edit_structure = [["+question", "Question"],
                          [:wikirate_topic, "Topic"]]
  end

  def tab_pane_id name
    "#{name.downcase}Pane"
  end

  def selected_tab_pane? name
    if params[:tab]
      params[:tab].casecmp(name).zero?
    else
      name == "Researched"
    end
  end

  def new_metric_tab_pane name
    new_metric = Card.new type: MetricID, "+*metric type" => "[[#{name}]]"
    new_metric.reset_patterns
    new_metric.include_set_modules
    tab_pane tab_pane_id(name), subformat(new_metric)._render_new_tab_pane,
             selected_tab_pane?(name)
  end

  view :help_text do |args|
    return "" unless (help_text_card = Card[card.metric_type + "+description"])
    subformat(help_text_card).render_content args
  end

  view :new_tab_pane do |args|
    card_form :create, hidden: args.delete(:hidden),
                       "main-success" => "REDIRECT" do
      output [
        new_tab_pane_hidden,
        _render(:help_text),
        _render_new_name_formgroup,
        _optional_render_content_formgroup,
        _optional_render_new_buttons
      ]
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
    output [
      metric_designer_field(options),
      '<div class="plus">+</div>',
      metric_title_field(options)
    ]
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
    title = card.add_subfield :title, content: card.cardname.tag,
                                      type_id: PhraseID
    title.reset_patterns
    title.include_set_modules
    subformat(title)._render_edit_in_form(options.merge(title: "Metric Title"))
  end
end
