include_set Abstract::CodeContent
include_set Abstract::FancyCounts
include_set Abstract::AboutPages
include_set Abstract::CompanySlider

# include_set Abstract::SolidCache, cached_format: :html
#
# cache_expire_trigger Card::Set::All::Base do |_changed_card|
#   Card[:homepage] if Codename.exist? :homepage
# end

def new_relic_label
  "home"
end

format :html do
  def layout_name_from_rule
    :deckorate_minimal_layout
  end

  %i[alert banner involved].each do |view|
    view view, template: :haml, cache: :always
  end

  view :core, template: :haml, cache: :deep, expire: :hour
  view :delta, template: :haml, wrap: :slot, cache: :never

  view :shuffle_button do
    link_to_view :delta, material_symbol_tag(:shuffle), class: "btn wr-arrow"
  end

  def alert?
    :alert_banner.card.content.strip.present?
  end

  def involved_links
    {
      "Join a project": "/:project",
      "Find our latest events": "",
      "Host your own project": "/new/:project",
      "Sign up": "/new/:signup"
    }
  end

  def edit_fields
    absolutize_edit_fields [
      :alert_banner,
      %i[cardtype featured],
      %i[homepage blurb],
      %i[metric featured],
      %i[dataset featured],
      :homepage_involved_heading,
      :homepage_delta_heading,
      %i[homepage metric],
      :homepage_designers_heading,
      %i[designer featured]
    ]
  end

  def count_categories
    %i[company metric answer source]
  end

  def delta_metric_card
    %i[homepage metric].card&.first_card
  end

  def trending value
    if value.negative?
      { sign: "", direction: "down" }
    elsif value.zero?
      { sign: "", direction: "flat" }
    else
      { sign: "+", direction: "up" }
    end
  end

  def companies_for_slider
    %i[designer featured].card&.item_cards || []
  end

  def company_detail company
    count = company.metrics_designed_card.count
    "#{count} #{:metric.cardname.pluralize count}"
  end

  def delta_answers
    return [] unless (metric = delta_metric_card)

    ma = metric.answer_card
    AnswerQuery.new(ma.query_hash.merge(latest: true), { random: "" }, limit: 10).run
  end
end
