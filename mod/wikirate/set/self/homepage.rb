include_set Abstract::CodeContent
include_set Abstract::FancyCounts
include_set Abstract::AboutPages

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

  %i[menu core search type_links involved delta designers].each do |view|
    view view, template: :haml
  end

  view :delta, template: :haml, wrap: :slot

  view :shuffle_button do
    link_to_view :delta, icon_tag(:shuffle), class: "btn wr-arrow"
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
      :homepage_search_heading,
      %i[search featured],
      %i[cardtype featured],
      %i[homepage blurb],
      # ] + count_categories.map { |c| [c, :header] } + [
      :homepage_involved_heading,
      :homepage_delta_heading,
      %i[homepage metric],
      :homepage_designers_heading,
      %i[designer featured]
    ]
  end

  def count_categories
    %i[wikirate_company metric metric_answer source]
  end

  def delta_metric_card
    %i[homepage metric].card&.first_card
  end

  def trending value
    if value.negative?
      { sign: "-", direction: "down" }
    elsif value.zero?
      { sign: "", direction: "flat" }
    else
      { sign: "+", direction: "up" }
    end
  end

  def delta_answers
    return [] unless (metric = delta_metric_card)

    ma = metric.metric_answer_card
    AnswerQuery.new(ma.query_hash.merge(latest: true), { random: "" }, limit: 10).run
  end
end
