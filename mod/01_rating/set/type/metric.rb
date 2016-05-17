card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :metric_type, type: :pointer, default: "[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type
card_accessor :report_type
card_accessor :research_policy
card_accessor :campaign

def metric_type
  metric_type_card.item_names.first
end

def metric_type_codename
  Card[metric_type].codename.to_sym
end

def metric_designer
  junction? ? cardname.parts[0] : creator.cardname
end

def metric_designer_card
  junction? ? self[0] : creator
end

def metric_title
  junction? ? cardname.parts[1] : cardname
end

def metric_title_card
  junction? ? self[1] : self
end

def question_card
  field "Question", new: {}
end

def value_type
  # FIXME: value type should have a codename
  (vt = field("value type")) && vt.item_names.first
end

def value_options
  (vo = field("value options")) && vo.item_names
end

def number_values?
  # FIXME: use codename
  value_type == "Number"
end

# TODO: adapt to Henry's value type API
def categorical?
  value_type == "Category"
end

def researched?
  metric_type_codename == :researched
end

def calculated?
  !researched?
end

# value between 0 and 10?
def scored?
  metric_type_codename == :score ||
    metric_type_codename == :wiki_rating
end

def analysis_names
  return [] unless (topics = fetch(trait: :wikirate_topic)) &&
                   (companies = fetch(trait: :wikirate_company))
  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company.to_name.tag}+#{topic}"
    end
  end.flatten
end

# def value company, year
#   (value_card = Card["#{name}+#{company}+#{year}+#{value}"]) &&
#     value_card.content
# end

def companies_with_years_and_values
  value_cards.map do |mv_card|
    [mv_card.company, mv_card.year, mv_card.value]
  end
end

def random_value_card
  value_cards(limit: 1).first
end

def random_valued_company_card
  return unless (rvc = random_value_card)
  rvc.company_card
end

def metric_value_cards opts={}
  Card.search metric_value_query.merge(opts)
end

def value_cards opts={}
  Card.search({ left: metric_value_query, right: "value" }.merge(opts))
end

def metric_value_name company, year
  company_name = Card.fetch_real_by_key(company).name
  "#{name}+#{company_name}+#{year}"
end

def metric_value_query
  { left: { left: name }, type_id: MetricValueID }
end

format :html do
  view :designer_image do |_args|
    image = nest card.metric_designer_card.field(:image, new: {}),
                 view: :core, size: :small
    card_link card.metric_designer_card, text: image
  end

  def css
    ""
    # css = <<-CSS
    # CSS
    # "<style> #{Sass.compile css}</style>"
  end

  view :legend do |_args|
    # depends on the type
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ""
    end
  end

  def item_wrap args
    with_nest_mode :normal do
      wrap args do
        <<-HTML
        <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
        <div class="yinyang-row">
          <div class="metric-item value-item">
            #{yield}
            <div class="details"></div>
          </div>
        </div>
        HTML
      end
    end
  end

  view :value_type_edit_modal_link do |args|
    value_type_card = card.fetch trait: :value_type, new: {}
    subformat_card = subformat(value_type_card)
    text =
      if value_type_card.new?
        "Update Value Type"
      else
        subformat_card.render(:shorter_pointer_content)
      end
    edit_args = {
      path_opts: {
        slot: {
          hide: "title,header,menu,help,subheader",
          view: :edit, edit_value_type: true
        }
      },
      html_args: {
        class: "btn btn-default slotter"
      },
      text: text
    }
    render_modal_link(args.merge(edit_args))
  end

  view :short_view do |_args|
    return "" unless (value_type = card.fetch trait: :value_type)

    details_field =
      case value_type.item_names[0]
      when "Number"   then :numeric_details
      when "Money"    then :monetary_details
      when "Category" then :category_details
      end
    return "" if details_field.nil?
    detail_card = Card.fetch card, details_field, new: {}
    subformat(detail_card).render_content
  end

  def default_edit_args args
    edit_args args
    super(args)
  end

  def edit_args args
    return unless args[:edit_value_type]
    args[:structure] = "metric value type edit structure"
  end

  def edit_slot args
    if args[:edit_value_type]
      super args.merge(core_edit: true)
    else
      super args
    end
  end

  view :handle do |_args|
    content_tag :div, class: "handle" do
      glyphicon "option-vertical"
    end
  end

  view :vote do |_args|
    %(<div class="hidden-xs hidden-md">{{#{card.name}+*vote count}}</div>)
  end

  view :value do |args|
    return "" unless args[:company]
    %(
      <div class="data-item hide-with-details">
        {{#{card.name}+#{args[:company]}+latest value|concise}}
      </div>
    )
  end

  def view_caching?
    true
  end

  view :item_view do |args|
    append = args[:append_for_details] ||
             "#{card.key}+add_to_formula"
    item_wrap(args) do
      %(
      <div class="no-data metric-details-toggle"
           data-append="#{append}">
        #{_render_thumbnail(optional_thumbnail_subtitle: :hide)}
      </div>
      )
    end
  end

  view :item_view_with_value do |args|
    contributions_url = path "#{metric_designer}+contributions"
    item_wrap args do
      <<-HTML
        <div class="header">
          #{_render_handle if args[:draggable]}
          #{_render_vote if args[:vote]}
          <a href="#{contributions_url}">
          <div class="logo hidden-xs hidden-md">
             #{nest card.metric_designer_card.fetch(trait: :image),
                    view: :core, size: 'small'}
          </div>
          </a>
          <div class="name">
            #{card_link card, text: metric_title, class: 'inherit-anchor'}
          </div>
        </div>
        <div class="data metric-details-toggle"
             data-append="#{card.key}+add_to_formula">
          #{_render_value(args)}
          <div class="data-item show-with-details text-center">
            <span class="label label-metric">
             #{card_link card, text: 'Metric Details'}
            </span>
          </div>
        </div>
      HTML
    end
  end

  view :add_to_formula do |_args|
    # .metric-details-close-icon.pull-right
    # i.fa.fa-times-circle.fa-2x
    # %br
    render_haml do
      <<-HAML
%br
.metric-details-header
  .row.clearfix
    .col-md-12
      .name.row
        = card_link card, text: card.metric_title, class: 'inherit-anchor'
      .row
        = _render_designer_info
  %hr
  .row.clearfix.wiki
    = _render_metric_info
      HAML
    end
  end

  view :metric_info do |_args|
    question = subformat(card.question_card)._render_core.html_safe
    rows = [
      icon_row("question", question, class: "metric-details-question"),
      icon_row("bar-chart", card.metric_type, class: "text-emphasized"),
      icon_row("tag", field_nest("+topic", view: :content, item: :link))
    ]
    if card.researched?
      rows <<  text_row("Unit", field_nest("Unit"))
      rows <<  text_row("Range", field_nest("Range"))
    end
    wrap_with :div, class: "metric-info" do
      rows
    end
  end

  def metric_info_row left_structure, right_content, opts={}
    <<-HTML
      <div class="row #{opts[:class]}">
        #{left_structure}
        <div class="row-data">
          #{right_content}
        </div>
      </div>
    HTML
  end

  def text_row text, content, opts={}
    left = <<-HTML
            <div class="left-col">
              <strong>#{text}</strong>
            </div>
          HTML
    metric_info_row left, content, opts
  end

  def icon_row icon, content, opts={}
    left = <<-HTML
            <div class="left-col icon-muted">
              #{fa_icon icon}
            </div>
          HTML
    metric_info_row left, content, opts
  end

  view :weight_row do |args|
    weight = text_field_tag("pair_value", (args[:weight] || 0)) + "%"
    output(
      [
        content_tag(:td, _render_thumbnail(args), "data-key" => card.name),
        content_tag(:td, weight, class: "metric-weight")
      ]
    ).html_safe
  end

  def interpret_year year
    case year
    when /^[+-]\d+$/
      "year#{args[:year]}"
    when /^\d{4}$/
      year
    when "0"
      "year"
    end
  end

  def get_value_str year
    "data[#{card.key}][#{year}]"
  end

  view :ruby do |args|
    if args[:sum]
      start, stop = args[:sum].split("..").map { |y| interpret_year(y) }
      "((#{start}..#{stop}).to_a.inject(0) { |r, y| r += #{get_value_str('y')}; r })"
    else
      year = args[:year] ? interpret_year(args[:year]) : "year"
      get_value_str year
    end
  end
end

format :json do
  view :content do
    card.companies_with_years_and_values.to_json
  end
end

def needs_name?
  # score names are handles differently in MetricType::Score
  !name.present? && metric_type != "Score"
end
