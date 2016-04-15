def create_value_options options
  create_args = {
    name: cardname.field('value options'),
    content: options.to_pointer_content
  }
  Card.create! create_args
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
    args['+source'] = {
      subcards: {
        'new source' => {
          '+Link' => {
            content: source,
            type_id: Card::PhraseID
          }
        }
      }
      # type_id: PointerID
    }
  when Hash
    args['+source'] = source
  when Card
    args['+source'] = {
      content: "[[#{source.name}]]",
      type_id: Card::PointerID
    }
  end
end

def valid_value_args? args
  missing = [:company, :year, :value].reject { |v| args[v] }
  error_msg = []
  error_msg += missing.map { |field| "missing #{field.to_sentence}" }
  metric_value_name = [name, args[:company], args[:year]].join '+'
  if Card[metric_value_name.to_name.field(:value)]
    error_msg << 'value already exists'
  end
  if metric_type_codename == :researched && !args[:source]
    error_msg << 'missing source'
  end
  if error_msg.present?
    error_msg.each do |msg|
      errors.add 'metric value', msg
    end
    return false
  end
  true
end

def create_value_args args
  return unless valid_value_args? args
  value_name = [name, args[:company], args[:year]].join '+'
  create_args = {
    name: value_name,
    type_id: Card::MetricValueID,
    '+value' => {
      content: args[:value],
      type_id: (args[:value].is_a?(Integer) ? NumberID : PhraseID)
    }
  }
  add_value_source_args create_args, args[:source]
  create_args
end

# @param [Hash] args
# @option args [String] :company
# @option args [String] :year
# @option args [String] :value
# @option args [String] :source source url
def create_value args
  Card.create! create_value_args(args)
end

# The new metric form has a title and a designer field instead of a name field
# We compose the card's name here
event :set_metric_name, :initialize,
      on: :create,
      when: proc { |c| c.needs_name? } do
  title = (tcard = remove_subfield(:title)) && tcard.content
  designer = (dcard = remove_subfield(:designer)) && dcard.content
  self.name = "#{designer}+#{title}"
end

format :html do
  # FIXME: inline js
  view :new do |args|
    # frame_and_form :create, args, 'main-success' => 'REDIRECT' do
    frame args.merge(title: 'New Metric') do
      <<-HTML
      <fieldset class="card-editor editor">
        <div role="tabpanel">
          <input class="card-content form-control" type="hidden" value=""
                 name="card[subcards][+*metric type][content]"
                 id="card_subcards___metric_type_content">
          #{new_metric_tab_buttons}
        </div>
      </fieldset>
      <!-- Tab panes -->
      #{new_metric_tab_content}
      <script>
        $('input[name="intervaltype"]').click(function () {
          //jQuery handles UI toggling correctly when we apply "data-target"
          // attributes and call .tab('show')
          //on the <li> elements' immediate children, e.g the <label> elements:
          $(this).closest('label').tab('show');
        });
      </script>
      HTML
    end
  end

  def default_content_formgroup_args args
    args[:edit_fields] = { '+question' => { title: 'Question' },
                           '+topic' => { title: 'Topic' },
                           '+report_type' => { title: 'Report Type' } }
  end

  def tab_radio_button id, active=false
    <<-HTML
    <li role="tab" class="pointer-radio #{'active' if active}">
      <label data-target="##{tab_pane_id id}">
        <input id="#{id}"
               name="intervaltype"
               value="#{id}"
               class="pointer-radio-button"
               type="radio" #{'checked' if active} />#{id}</label>
    </li>
    HTML
  end

  def new_metric_tab_buttons
    wrap_with :ul, class: 'nav nav-tabs', role: 'tablist' do
      %w(Researched Formula Score WikiRating).map.with_index do |metric_type, i|
        tab_radio_button metric_type, (i == 0)
      end
    end
  end

  def new_metric_tab_content
    wrap_with :div, class: 'tab-content' do
      %w(Researched Formula Score WikiRating).map.with_index do |metric_type, i|
        new_metric_tab_pane metric_type, (i == 0)
      end
    end
  end

  def tab_pane_id name
    "#{name.downcase}Pane"
  end

  def new_metric_tab_pane name, active=false
    new_metric = Card.new type: MetricID, '+*metric type' => "[[#{name}]]"
    new_metric.reset_patterns
    new_metric.include_set_modules
    tab_pane tab_pane_id(name), subformat(new_metric)._render_new_tab_pane,
             active
  end

  view :new_tab_pane do |args|
    card_form :create, hidden: args.delete(:hidden),
                       'main-success' => 'REDIRECT' do
      output [
        _render(:name_formgroup, args),
        _render(:content_formgroup, args),
        _render(:button_formgroup, args)
      ]
    end
  end

  def default_new_tab_pane_args args
    default_new_args_buttons args
    args[:hidden] ||= {
      'card[subcards][+*metric type][content]' => "[[#{card.metric_type}]]",
      'card[type_id]' => MetricID,
      success: '_self'
    }
  end

  view :name_formgroup do |args|
    formgroup 'Metric Name', raw(name_field(form)), editor: 'name',
                                                    help: args[:help]
  end

  def name_field form=nil, options={}
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
      ._render_edit_in_form(options.merge(title: 'Metric Designer'))
    # end
  end

  def metric_title_field _options={}
    title = card.add_subfield :title, content: card.cardname.tag,
                                      type_id: PhraseID
    subformat(title)._render_edit_in_form(options.merge(title: 'Metric Title'))
  end
end
