card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"

card_accessor :metric_type,
              :type=>:pointer, :default=>"[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type

def metric_type
  metric_type_card.item_names.first
end

def designer
  cardname.parts[0]
end

def designer_card
  self[0]
end

def metric_title
  cardname.parts[1]
end

def metric_title_card
  self[1]
end

def metric_type_codename
  Card[metric_type].codename
end

def value_type
  # FIXME: value type should have a codename
  (vt = field('value type')) && vt.item_names.first
end

# TODO: adapt to Henry's value type API
def categorical?
  value_type == 'Categorical'
end

    # def value company, year
#   (value_card = Card["#{name}+#{company}+#{year}+#{value}"]) &&
#     value_card.content
# end

def create_value args
  missing = [:company, :year, :value].reject { |v| args[v] }
  if missing.present?
    errors.add 'metric value', "missing #{missing.to_sentence}"
    return
  end
  create_args = {
    name: "#{name}+#{args[:company]}+#{args[:year]}",
    type_id: Card::MetricValueID,
    '+value' => {
      content: args[:value],
      type_id: (args[:value].is_a?(Integer) ? NumberID : PhraseID)
    }
  }
  if metric_type_codename == :reseached
    if !args[:source]
      errors.add 'metric value', "missing source"
      return
    end
    create_args[:source] = args[:source]
  end
  Card.create! create_args
end

def companies_with_years_and_values
  Card.search(right: 'value', left: {
    left: { left: card.name },
    right: { type: 'year' }
    }).map do |card|
      [
        card.cardname.left_name.left_name.right,
        card.cardname.left_name.right, card.content
      ]
  end
end

def random_value_card
  Card.search(right: 'value',
              left: {
                left: { left: name },
                right: { type: 'year' }
              },
              limit: 1).first
end

def random_company_card_with_value
  return unless rvc = random_value_card
  rvc.left.left.right
end

format :html do
  view :tabs do |args|
    lazy_loading_tabs args[:tabs], args[:default_tab],
                      render("#{args[:default_tab]}_tab", skip_permission: true)
  end
  def default_tabs_args args
    args[:tabs] = {
      'Details' => path(view: 'details_tab'),
      "#{fa_icon :comment} Discussion" => path(view: 'discussion_tab')
    }
    args[:default_tab] = 'Details'
  end

  # tabs for metrics of type formula, score and WikiRating
  # overriden for researched
  view :details_tab do
    output [
             nest(card.formula_card, view: :titled, title: 'Formula'),
             nest(card.about_card, view: :titled, title: 'About')
           ]
  end

  view :discussion_tab do |args|
    _render_comment_box(args)
  end

  view :thumbnail do |args|
    wrap_with :div, class: 'metric-thumbnail' do
      [
        _render_thumbnail_image(args),
        _render_thumbnail_text(args),
        css
      ]
    end
  end

  def css
    css = <<-CSS
    .titled-view.TYPE_PLUS_RIGHT-metric-formula {
      .TYPE_PLUS_RIGHT-metric-formula.card-content {
        font-size: 1.5em;
        font-weight: bold;
      }
    }
      .metric-thumbnail {
        font-size: 0.66em;
        font-weight: normal;
        border: solid 1px #ebebeb;
        display: inline-block;
        padding: 7px;
        img {
          max-width: 35px;
          max-height: 35px;
        }
        .thumbnail-image, .thumbnail-text {
          display: inline-block;
          vertical-align: middle;
        }
      }
    CSS
    "<style> #{Sass.compile css}</style>"
  end

  view :thumbnail_image do |_args|
    wrap_with :div, class: 'thumbnail-image' do
      nest card.designer_card.field(:image, new: {}), view: :core, size: :small
    end
  end

  view :thumbnail_text do |args|
    wrap_with :div, class: 'thumbnail-text' do
      [
        _render_thumbnail_title(args),
        _render_thumbnail_subtitle(args)
      ]
    end
  end

  view :thumbnail_title do |args|
    content_tag(:div, nest(card.metric_title_card, view: :name))
  end

  view :thumbnail_subtitle do |args|
    content_tag :div do
      <<-HTML
      <small class="text-muted">
        #{args[:text]}
        #{args[:author]}
      </small>
      HTML
    end
  end
  def default_thumbnail_subtitle_args args
    args[:text] ||= [card.value_type, 'designed by'].compact.join ' | '
    args[:author] ||= card_link card.designer
  end

  def tab_radio_button id, active=false
    <<-HTML
    <li role="tab" class="pointer-radio #{'active' if active}">
      <label data-target="##{tab_pane_id id}">
        <input id="#{id}" name="intervaltype"
               value="#{id}"
               class="pointer-radio-button"
               type="radio" #{'checked' if active} />
          #{id}
        </label>
    </li>
    HTML
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

  def new_metric_tab_content
    wrap_with :div, class: 'tab-content' do
      %w(Researched Formula Score WikiRating).map.with_index do |metric_type, i|
        new_metric_tab_pane metric_type, (i == 0)
      end
    end
  end

  def new_metric_tab_buttons
    wrap_with :ul, class: 'nav nav-tabs', role: 'tablist' do
      %w(Researched Formula Score WikiRating).map.with_index do |metric_type, i|
        tab_radio_button metric_type, (i == 0)
      end
    end
  end

  view :new do |args|
    #frame_and_form :create, args, 'main-success' => 'REDIRECT' do
    frame args.merge(title: 'New Metricj') do
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

  def default_content_formgroup_args args
    args[:structure] = 'metric+*type+*edit structure'
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
    formgroup 'Metric Name', raw(name_field form), editor: 'name', help:
      args[:help]
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
      nest designer, options.merge(view: :editor, title: 'Metric Designer')
    # end
  end

  def metric_title_field options={}
    title = card.add_subfield(:title, content: card.cardname.tag,
                                 type_id: PhraseID)
    #with_nest_mode :edit  do
      nest title, view: :editor, title: 'Metric Title'
   # end
    # text_field('subcards[+*title]', {
    #   value: card.name,
    #   autocomplete: 'off'
    # }.merge(options))
  end

  view :legend do |args|
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ''
    end
  end

  view :item_view do |args|
    handle =
      if args[:draggable]
        <<-HTML
          <div class="handle">
            <span class="glyphicon glyphicon-option-vertical"></span>
          </div>
        HTML
      end

    value =
      if args[:company]
        <<-HTML
          <div class="data-item hide-with-details">
            {{#{card.name}+#{args[:company]}+latest value|concise}}
          </div>
        HTML
      end

    vote =
      if args[:vote]
        %(<div class="hidden-xs hidden-md">{{#{card.name}+*vote count}}</div>)
      end
    metric_designer = card.cardname.left
    metric_name = card.cardname.right

    html = <<-HTML
    <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
    <div class="yinyang-row">
    <div class="metric-item value-item">
      <div class="header metric-details-toggle"
           data-append="#{card.key}+add_to_formula">
        #{handle}
        #{vote}
        <div class="logo hidden-xs hidden-md">
          {{#{metric_designer}+image|core;size:small}}
        </div>
        <div class="name">
            {{#{metric_name}|name}}
        </div>
      </div>
      <div class="details"></div>
    </div>
  </div>
    HTML
    with_nest_mode :normal do
      wrap args do
        process_content html
      end
    end
  end


  view :item_view_with_value do |args|
    handle =
      if args[:draggable]
        <<-HTML
          <div class="handle">
            <span class="glyphicon glyphicon-option-vertical"></span>
          </div>
        HTML
      end

    value =
      if args[:company]
        <<-HTML
          <div class="data-item hide-with-details">
            {{#{card.name}+#{args[:company]}+latest value|concise}}
          </div>
        HTML
      end

    vote =
      if args[:vote]
        %(<div class="hidden-xs hidden-md">{{#{card.name}+*vote count}}</div>)
      end
    metric_designer = card.cardname.left
    metric_name = card.cardname.right

    html = <<-HTML
    <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
    <div class="yinyang-row">
    <div class="metric-item value-item">
      <div class="header">
        #{handle}
        #{vote}
        <a href="{{_llr+contributions|linkname}}">
        <div class="logo hidden-xs hidden-md">
          {{#{metric_designer}+image|core;size:small}}
        </div>
        </a>
        <div class="name">
          <a class="inherit-anchor" href="{{#{card.name}|linkname}}">
            {{#{metric_name}|name}}
          </a>
        </div>
      </div>
      <div class="data metric-details-toggle"
           data-append="#{card.key}+add_to_formula">
        #{value}
        <div class="data-item show-with-details text-center">
          <span class="label label-metric">
            [[#{card.name}|Metric Details]]
          </span>
        </div>
      </div>
      <div class="details">
      </div>
    </div>
  </div>
    HTML
    with_nest_mode :normal do
      wrap args do
        process_content html
      end
    end
  end

  def view_caching?
    true
  end
end

def analysis_names
  return [] unless (topics = Card["#{name}+#{Card[:wikirate_topic].name}"]) &&
                   (companies = Card["#{name}+#{Card[:wikirate_company].name}"])

  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company}+#{topic}"
    end
  end.flatten
end

format :json do
  view :content do
    companies_with_years_and_values.to_json
  end
end

event :set_metric_name, :initialize,
      on: :create do
  return if name.present? || metric_type == 'Score'
  title = (tcard = remove_subfield(:title)) && tcard.content
  designer = (dcard = remove_subfield(:designer)) && dcard.content
  self.name = "#{designer}+#{title}"
end
