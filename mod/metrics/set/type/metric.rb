require "savanna-outliers"

include_set Abstract::Export
include_set Abstract::DesignerAndTitle
include_set Abstract::MetricThumbnail

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :metric_type, type: :pointer, default: "[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type
card_accessor :value_options
card_accessor :report_type
card_accessor :research_policy
card_accessor :project
card_accessor :all_metric_values
card_accessor :unit
card_accessor :range
card_accessor :currency

def metric_type
  metric_type_card.item_names.first
end

def metric_type_codename
  Card[metric_type].codename.to_sym
end

def metric_type_id
  Card[metric_type].id
end

# @return array of metric answer lookup table
def all_answers
  Answer.where(metric_id: id)
end

def answer company, year
  company = Card.fetch_id(company) unless company.is_a? Integer
  Answer.where(metric_id: id, company_id: company, year: year.to_i).take
end

def distinct_values
  all_answers.select(:value).distinct.pluck(:value)
end

def question_card
  field "Question", new: {}
end

def value_type
  value_type_card.item_names.first || default_value_type
end

def default_value_type
  "Free Text"
end

def value_type_code
  ((vc = value_type_card.item_cards.first) &&
    vc.codename && vc.codename.to_sym) || default_value_type_code
end

def default_value_type_code
  :free_text
end

def value_options
  value_options_card.item_names
end

def numeric?
  # FIXME: value type options should have a codename
  value_type.in?(%(Number Money)) || !researched?
end

# TODO: adapt to Henry's value type API
def categorical?
  value_type == "Category" || value_type == "Multi-Category"
end

def relationship?
  metric_type_codename.in? [:relationship, :inverse_relationship]
end

def inverse?
  metric_type_codename == :inverse_relationship
end

def multi_categorical?
  value_type_code == :multi_category
end

def standard?
  metric_type_codename == :researched
end

def researched?
  standard? || relationship?
end

def calculated?
  !researched?
end

# value between 0 and 10?
def rated?
  metric_type_codename == :wiki_rating
end

def scored?
  metric_type_codename == :score || rated?
end

def designer_assessed?
  research_policy.casecmp("designer assessed").zero?
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

def companies_with_years_and_values
  Answer.search(metric_id: id, return: [:company, :year, :value]).map do |c, y, v|
    [c, y.to_s, v]
  end
end

def random_value_card
  Answer.search(metric_id: id, limit: 1).first
end

def random_valued_company_card
  Answer.search(metric_id: id, return: :company_card, limit: 1).first
end

def metric_value_cards cached: true
  cached ? Answer.search(metric_id: id) : Card.search(metric_value_query)
end

def value_cards _opts={}
  Answer.search metric_id: id, return: :value_card
end

def metric_value_name company, year
  Card::Name[name, Card.fetch_name(company), year.to_s]
end

def metric_value_query
  { left: { left_id: id }, type_id: MetricValueID }
end

event :silence_metric_deletions, :initialize, on: :delete do
  @silent_change = true
end

format :html do
  def prepare_for_outlier_search
    res = {}
    card.all_metric_values_card.values_by_name.map do |key, data|
      data.each do |row|
        res["#{key}+#{row['year']}"] = row["value"].to_i
      end
    end
    res
  end

  view :outliers do
    outs = Savanna::Outliers.get_outliers prepare_for_outlier_search, :all
    outs.inspect
  end

  def css
    ""
    # css = <<-CSS
    # CSS
    # "<style> #{Sass.compile css}</style>"
  end

  # USED?

  view :add_to_formula_item_view do |_args|
    subtext = wrap_with :small, "Designed by #{card.metric_designer}"
    add_to_formula_helper subtext
  end

  def add_to_formula_helper subtext
    title = card.metric_title.to_s
    append = "#{params[:formula_metric_key]}+add_to_formula"
    url = path mark: card.name.field(append), view: :content
    text_with_image image: designer_image_card,
                    text: subtext, title: title, size: :icon,
                    media_opts: { class: "slotter _clickable",
                                  href: url,
                                  data: {
                                    remote: true,
                                    "slot-selector": ".metric-details-slot > .card-slot"
                                  } }
  end

  view :details_placeholder do
    ""
  end

  view :listing do
    wrap_with :div, class: "contribution-item value-item no-hover" do
      [
        wrap_with(:div, class: "header") do
          _render_thumbnail
        end,
        wrap_with(:div, class: "text-center") do
          listing_data
        end
      ]
    end
  end

  def listing_data
    wrap_with :div, class: "contribution company-count p-2" do
      [
        wrap_with(:span, company_count, class: "badge badge-secondary"),
        wrap_with(:span, "Companies", class: "text-muted")
      ]
    end
  end

  def company_count
    card.fetch(trait: :wikirate_company).cached_count
  end

  view :legend do
    value_legend
  end

  def value_legend
    # depends on the type
    if card.unit.present?
      card.unit
    elsif card.range.present?
      "/#{card.range}"
    elsif card.categorical?
      "/#{category_legend}"
    else
      ""
    end
  end

  def category_legend
    card.value_options.reject { |o| o == "Unknown" }.join ","
  end

  def item_wrap
    with_nest_mode :normal do
      wrap do
        <<-HTML
        <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
        <div class="yinyang-row">
          <div class="metric-item value-item ">
            #{yield}
            <div class="details"></div>
          </div>
        </div>
        HTML
      end
    end
  end

  view :value_type_edit_modal_link, cache: :never do
    nest card.value_type_card,
         view: :modal_link,
         link_text: vtype_edit_modal_link_text,
         link_opts: { class: "btn btn-outline-secondary slotter value-type-button",
                      path: {
                        slot: {
                          hide: "header,menu,help",
                          view: :edit,
                          title: "Value Type"
                        }
                      } }
  end

  def vtype_edit_modal_link_text
    # FIXME: why does value_type_card not work although value_type is registered
    #        as card accessor
    v_type_card = card.fetch trait: :value_type, new: {}
    if v_type_card.new?
      "Update Value Type"
    else
      nest v_type_card, view: :shorter_pointer_content, hide: :link
    end
  end

  view :short_view do |_args|
    return "" unless (value_type = card.fetch trait: :value_type)

    details_field =
      case value_type.item_names[0]
      when "Number" then
        :numeric_details
      when "Money" then
        :monetary_details
      when "Category", "Multi-Category" then
        :category_details
      end
    return "" if details_field.nil?
    detail_card = Card.fetch card, details_field, new: {}
    subformat(detail_card).render_content
  end

  view :handle do |_args|
    wrap_with :div, class: "handle" do
      glyphicon "option-vertical"
    end
  end

  view :vote do |_args|
    %(<div class="hidden-xs hidden-md">
    #{field_nest(:vote_count)}</div>
    )
  end

  view :value do |args|
    return "" unless args[:company]
    %(
      <div class="data-item hide-with-details">
        {{#{card.name}+#{args[:company]}+latest value|concise}}
      </div>
    )
  end

  view :add_to_formula, template: :haml

  view :metric_info do |_args|
    question = subformat(card.question_card)._render_core.html_safe
    rows = [
      icon_row("question", question, class: "metric-details-question"),
      icon_row("bar-chart", card.metric_type, class: "text-emphasized"),
      icon_row("tag", field_nest("+topic", view: :content, items: { view: :link }))
    ]
    if card.researched?
      rows << text_row("Unit", field_nest("Unit"))
      rows << text_row("Range", field_nest("Range"))
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

  def weight_content args
    icon_class = "pull-right _remove_row btn btn-outline-secondary btn-sm"
    wrap_with :div do
      [
        text_field_tag("pair_value", (args[:weight] || 0)) + "%",
        content_tag(:span, fa_icon(:close).html_safe, class: icon_class)
      ]
    end
  end

  view :weight_row do |args|
    weight = weight_content args
    output(
      [
        wrap_with(:td, _render_thumbnail_plain(args), "data-key" => card.name),
        wrap_with(:td, weight, class: "metric-weight")
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

  view :ruby, cache: :never do |args|
    if args[:sum]
      start, stop = args[:sum].split("..").map { |y| interpret_year(y) }
      "((#{start}..#{stop}).to_a.inject(0) " \
      "{ |r, y| r += #{get_value_str('y')}; r })"
    else
      year = args[:year] ? interpret_year(args[:year]) : "year"
      get_value_str year
    end
  end
end

format :json do
  # view :content do
  #   card.companies_with_years_and_values.to_json
  # end

  view :core do
    card.all_answers.map do |answer|
      # nest answer, view: :essentials
      subformat(answer)._render_core
    end
  end

  def essentials
    {
      designer: card.metric_designer,
      title: card.metric_title
    }
  end
end

def needs_name?
  # score names are handles differently in MetricType::Score
  !name.present? && metric_type != "Score"
end

format :csv do
  view :core do
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end
end
